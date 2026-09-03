#!/bin/sh
# Suplemon uninstaller.
#
#   sh uninstall.sh                 # from a checkout
#   curl -fsSL .../uninstall.sh | sh
#
# Options (with the pipe, pass them after "sh -s --"):
#   --purge     also remove ~/.config/suplemon (config, keymap, logs)
#   --dry-run   show what would be removed, remove nothing
#
# Removes only what the installer created, and only when it can tell that
# it created it. Leaves ~/.local/bin itself alone, since other programs
# live there.
set -eu

SRC_DIR="$HOME/.local/src/suplemon"
BIN_DIR="$HOME/.local/bin"
LAUNCHER="$BIN_DIR/suplemon"
SHORTCUT="$BIN_DIR/se"
CONFIG_DIR="$HOME/.config/suplemon"

main() {
    purge=0
    dry=0
    for arg in "$@"; do
        case "$arg" in
            --purge)   purge=1 ;;
            --dry-run) dry=1 ;;
            -h|--help)
                printf 'Usage: uninstall.sh [--purge] [--dry-run]\n'
                printf '  --purge    also remove %s\n' "$CONFIG_DIR"
                printf '  --dry-run  show what would happen, change nothing\n'
                exit 0 ;;
            *) printf 'Unknown option: %s (try --help)\n' "$arg" >&2; exit 1 ;;
        esac
    done

    if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
        B=$(tput bold); G=$(tput setaf 2); Y=$(tput setaf 3); R=$(tput setaf 1); N=$(tput sgr0)
    else
        B=''; G=''; Y=''; R=''; N=''
    fi

    step() { printf '\n%s==>%s %s%s%s\n' "$G" "$N" "$B" "$*" "$N"; }
    info() { printf '    %s\n' "$*"; }
    ok()   { printf '    %s+%s %s\n' "$G" "$N" "$*"; }
    warn() { printf '    %s!%s %s\n' "$Y" "$N" "$*"; }
    skip() { printf '    %s-%s %s\n' "$Y" "$N" "$*"; }

    removed=0
    kept=0

    # Do it, or say what would have been done.
    doit() {
        if [ "$dry" = "1" ]; then
            printf '    %s~%s would remove %s\n' "$Y" "$N" "$1"
        else
            rm -rf "$1"
            ok "Removed $1"
        fi
        removed=$((removed + 1))
    }

    printf '%s\n' "${B}Suplemon uninstaller${N}"
    [ "$dry" = "1" ] && warn "Dry run: nothing will be changed."
    info "Removes the launchers and $SRC_DIR."
    info "$BIN_DIR itself is left alone."

    # Step out of the directory we are about to delete. Removing the shell's
    # own working directory leaves the now empty directory pinned until the
    # process exits, so it looks as though the removal failed. Every path here
    # is absolute, so the working directory does not matter otherwise.
    here=$(pwd -P 2>/dev/null || pwd)
    case "$here" in
        "$SRC_DIR"|"$SRC_DIR"/*)
            if cd "$HOME" 2>/dev/null || cd / 2>/dev/null; then
                info "Stepped out of $SRC_DIR into $(pwd), so it can be removed cleanly."
            else
                warn "Could not leave $SRC_DIR; an empty directory may be left behind."
            fi
            ;;
    esac

    ####################################################################
    step "Removing the 'se' shortcut"
    if [ -L "$SHORTCUT" ]; then
        target=$(readlink "$SHORTCUT")
        case "$target" in
            suplemon|"$LAUNCHER")
                doit "$SHORTCUT" ;;
            *)
                skip "$SHORTCUT points at '$target', not ours. Left alone."
                kept=$((kept + 1)) ;;
        esac
    elif [ -e "$SHORTCUT" ]; then
        skip "$SHORTCUT is a real file, not our symlink. Left alone."
        kept=$((kept + 1))
    else
        info "No se shortcut to remove"
    fi

    ####################################################################
    step "Removing the launcher"
    if [ -e "$LAUNCHER" ]; then
        if grep -q 'SUPLEMON_HOME' "$LAUNCHER" 2>/dev/null; then
            doit "$LAUNCHER"
        else
            skip "$LAUNCHER was not written by the installer. Left alone."
            kept=$((kept + 1))
        fi
    else
        info "No launcher to remove"
    fi
    if [ -e "$LAUNCHER.bak" ]; then
        info "Left $LAUNCHER.bak in place (it was yours, saved during install)"
    fi

    ####################################################################
    step "Removing the source checkout"
    if [ ! -e "$SRC_DIR" ]; then
        info "Nothing at $SRC_DIR"
    elif [ ! -f "$SRC_DIR/suplemon.py" ] || [ ! -d "$SRC_DIR/suplemon" ]; then
        skip "$SRC_DIR does not look like a Suplemon checkout. Left alone."
        kept=$((kept + 1))
    elif [ -d "$SRC_DIR/.git" ] && [ -n "$(git -C "$SRC_DIR" status --porcelain 2>/dev/null)" ]; then
        warn "$SRC_DIR has uncommitted changes, so it is being kept."
        info "Your work is safe. Review it with:"
        info "    git -C $SRC_DIR status"
        info "Then remove it yourself if you are sure:"
        info "    rm -rf $SRC_DIR"
        kept=$((kept + 1))
    else
        info "Includes the virtualenv inside it"
        doit "$SRC_DIR"
        # Tidy the parent only when we emptied it and nothing else lives there.
        parent=$(dirname "$SRC_DIR")
        if [ "$dry" = "0" ] && [ -d "$parent" ] && [ -z "$(ls -A "$parent" 2>/dev/null)" ]; then
            rmdir "$parent" 2>/dev/null && ok "Removed the now empty $parent" || true
        fi
    fi

    ####################################################################
    step "Configuration"
    if [ ! -d "$CONFIG_DIR" ]; then
        info "No config directory at $CONFIG_DIR"
    elif [ "$purge" = "1" ]; then
        info "Config, keymap, module storage and logs"
        doit "$CONFIG_DIR"
    else
        info "Keeping $CONFIG_DIR (your settings and keymap)"
        info "Remove it too with:  sh uninstall.sh --purge"
        kept=$((kept + 1))
    fi

    ####################################################################
    step "Left in place on purpose"
    info "$BIN_DIR, because other programs live there"
    for f in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
        if [ -f "$f" ] && grep -q 'Added by the Suplemon installer' "$f" 2>/dev/null; then
            info "The PATH block in $f, since $BIN_DIR stays"
            info "  remove it by hand if you want it gone"
        fi
    done

    ####################################################################
    if [ "$dry" = "1" ]; then
        printf '\n%sDry run complete.%s %s item(s) would be removed.\n\n' "$B" "$N" "$removed"
    else
        printf '\n%sDone.%s %s removed, %s kept.\n' "$G$B" "$N" "$removed" "$kept"
        if command -v suplemon >/dev/null 2>&1 || command -v se >/dev/null 2>&1; then
            printf '\n'
            warn "A 'suplemon' or 'se' command is still on your PATH:"
            command -v suplemon 2>/dev/null | sed 's/^/      /'
            command -v se 2>/dev/null | sed 's/^/      /'
            info "That one did not come from this installer."
        fi
        printf '\n'
    fi
}

main "$@"
