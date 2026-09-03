#!/bin/sh
# Suplemon installer.
#
#   curl -fsSL https://raw.githubusercontent.com/leancode/suplemon/master/install.sh | sh
#
# Installs into your home directory only. Never uses sudo, never touches
# anything outside ~/.local. Safe to re-run: it updates an existing install
# rather than starting over.
set -eu

REPO_URL="https://github.com/leancode/suplemon.git"
SRC_DIR="$HOME/.local/src/suplemon"
BIN_DIR="$HOME/.local/bin"
# Where sudo can see it. Overridable for testing and odd prefixes.
SYS_BIN_DIR="${SYS_BIN_DIR:-/usr/local/bin}"
LAUNCHER="$BIN_DIR/suplemon"
SHORTCUT="$BIN_DIR/se"
PY_MIN="3.8"

# Everything lives in main() so a truncated download can't execute half a
# script: the final line that calls it wouldn't have arrived.
main() {
    if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
        B=$(tput bold); G=$(tput setaf 2); Y=$(tput setaf 3); R=$(tput setaf 1); N=$(tput sgr0)
    else
        B=''; G=''; Y=''; R=''; N=''
    fi

    step()  { printf '\n%s==>%s %s%s%s\n' "$G" "$N" "$B" "$*" "$N"; }
    info()  { printf '    %s\n' "$*"; }
    ok()    { printf '    %s+%s %s\n' "$G" "$N" "$*"; }
    warn()  { printf '    %s!%s %s\n' "$Y" "$N" "$*"; }
    die()   { printf '\n%sError:%s %s\n\n' "$R" "$N" "$*" >&2; exit 1; }

    needs_export=0

    printf '%s\n' "${B}Suplemon installer${N}"
    info "Installs to $SRC_DIR and $BIN_DIR. No sudo, nothing outside \$HOME."

    ####################################################################
    step "Checking your platform"
    os=$(uname -s)
    case "$os" in
        Linux|FreeBSD|Darwin|OpenBSD|NetBSD)
            ok "$os $(uname -r) is supported" ;;
        *)
            warn "$os is untested. Suplemon needs a curses-capable terminal."
            warn "Continuing anyway." ;;
    esac

    ####################################################################
    step "Checking requirements"

    command -v git >/dev/null 2>&1 || die "git is not installed. Install it and re-run."
    ok "git $(git --version 2>/dev/null | awk '{print $3}')"

    command -v python3 >/dev/null 2>&1 || die "python3 is not installed. Install it and re-run."
    py_ver=$(python3 -c 'import sys; print("%d.%d" % sys.version_info[:2])' 2>/dev/null) \
        || die "python3 exists but could not run."
    if python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 8) else 1)' 2>/dev/null; then
        ok "python3 $py_ver (need $PY_MIN or newer)"
    else
        die "python3 is $py_ver, but Suplemon needs $PY_MIN or newer."
    fi

    # Debian and Ubuntu ship venv in a separate package, so importing it is
    # not enough of a check on its own.
    if python3 -c 'import venv, ensurepip' >/dev/null 2>&1; then
        ok "python3 venv support"
    else
        info "python3 cannot create virtual environments."
        if command -v apt-get >/dev/null 2>&1; then
            die "Install it with:  sudo apt install python3-venv"
        fi
        die "Install your distribution's python3 venv package and re-run."
    fi

    if command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1; then
        ok "network tools present"
    fi

    ####################################################################
    step "Fetching the source"
    if [ -d "$SRC_DIR/.git" ]; then
        info "Existing checkout at $SRC_DIR"
        if [ -n "$(git -C "$SRC_DIR" status --porcelain 2>/dev/null)" ]; then
            warn "You have local changes there, so it will not be updated."
            warn "Commit or stash them and re-run to get the latest version."
        else
            branch=$(git -C "$SRC_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo HEAD)
            info "Updating $branch from origin"
            if git -C "$SRC_DIR" pull --ff-only >/dev/null 2>&1; then
                ok "Updated to $(git -C "$SRC_DIR" log --oneline -1)"
            else
                warn "Could not fast-forward. Leaving the checkout as it is."
            fi
        fi
    else
        [ -e "$SRC_DIR" ] && die "$SRC_DIR exists but is not a git checkout. Move it aside and re-run."
        info "Cloning $REPO_URL"
        mkdir -p "$(dirname "$SRC_DIR")"
        git clone --quiet "$REPO_URL" "$SRC_DIR" || die "Clone failed."
        ok "Cloned to $SRC_DIR"
        ok "At $(git -C "$SRC_DIR" log --oneline -1)"
    fi

    ####################################################################
    step "Setting up the Python environment"
    venv="$SRC_DIR/venv"
    if [ -x "$venv/bin/python" ]; then
        info "Reusing the existing environment"
    else
        info "Creating a virtual environment in $venv"
        python3 -m venv "$venv" || die "Could not create the virtual environment."
        ok "Created"
    fi

    info "Installing wcwidth (required) and pygments (syntax highlighting)"
    if "$venv/bin/python" -m pip install --quiet --upgrade pip >/dev/null 2>&1; then :; fi
    "$venv/bin/python" -m pip install --quiet --upgrade wcwidth pygments \
        || die "Installing dependencies failed. Are you online?"
    for mod in wcwidth pygments; do
        "$venv/bin/python" -c "import $mod" 2>/dev/null && ok "$mod ready" || warn "$mod did not import"
    done

    ####################################################################
    step "Installing the launcher"
    mkdir -p "$BIN_DIR"
    if [ -e "$LAUNCHER" ] && ! grep -q 'SUPLEMON_HOME' "$LAUNCHER" 2>/dev/null; then
        cp "$LAUNCHER" "$LAUNCHER.bak"
        warn "$LAUNCHER existed and was not ours; saved it as $LAUNCHER.bak"
    fi
    cat > "$LAUNCHER" <<LAUNCHER_EOF
#!/bin/sh
# Run suplemon from the git checkout using its own venv, from any directory.
# Installed by install.sh. Re-run that script to update.
#
# The path below is absolute on purpose. It is expanded when install.sh
# writes this file, not when the launcher runs, because \$HOME is not the
# invoking user's home under sudo or su: it becomes root's, and the
# launcher would look for the venv in the wrong place and fail.
SUPLEMON_HOME="$SRC_DIR"
exec "\$SUPLEMON_HOME/venv/bin/python" "\$SUPLEMON_HOME/suplemon.py" "\$@"
LAUNCHER_EOF
    chmod +x "$LAUNCHER"
    ok "Wrote $LAUNCHER"

    ####################################################################
    step "Adding the 'se' shortcut"
    if [ -L "$SHORTCUT" ] && [ "$(readlink "$SHORTCUT")" = "suplemon" ]; then
        ok "se already points at suplemon"
    elif [ -e "$SHORTCUT" ] || [ -L "$SHORTCUT" ]; then
        warn "$SHORTCUT already exists and is not our symlink. Leaving it alone."
    else
        # Only claim the name if nothing else on the system answers to it.
        existing=$(command -v se 2>/dev/null || true)
        if [ -n "$existing" ]; then
            warn "'se' is already provided by $existing. Not creating a shortcut."
        else
            ln -s suplemon "$SHORTCUT"
            ok "Linked se -> suplemon"
        fi
    fi

    ####################################################################
    step "Making sure $BIN_DIR is on your PATH"
    case ":${PATH}:" in
        *":$BIN_DIR:"*)
            ok "Already on your PATH for this session"
            ;;
        *)
            # It may already be configured but not yet active: several
            # distributions add ~/.local/bin from ~/.profile only if the
            # directory existed at login, and we may have just created it.
            configured=""
            for f in "$HOME/.profile" "$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/.zshrc"; do
                [ -f "$f" ] || continue
                if grep -q '\.local/bin' "$f" 2>/dev/null; then
                    configured="$f"
                    break
                fi
            done
            if [ -n "$configured" ]; then
                ok "Already configured in $configured, but not active in this shell"
                needs_export=1
            else
                shell_name=$(basename "${SHELL:-/bin/sh}")
                case "$shell_name" in
                    zsh)  profile="$HOME/.zshrc" ;;
                    bash) profile="$HOME/.bashrc" ;;
                    fish) profile="" ;;
                    *)    profile="$HOME/.profile" ;;
                esac
                if [ -z "$profile" ]; then
                    warn "Your shell is fish, which uses different syntax."
                    needs_export=2
                else
                    [ -f "$profile" ] && cp "$profile" "$profile.bak" && \
                        info "Backed up $profile to $profile.bak"
                    {
                        printf '\n# Added by the Suplemon installer\n'
                        printf 'if [ -d "$HOME/.local/bin" ] ; then\n'
                        printf '    PATH="$HOME/.local/bin:$PATH"\n'
                        printf 'fi\n'
                    } >> "$profile"
                    ok "Added $BIN_DIR to your PATH in $profile"
                    needs_export=1
                fi
            fi
            ;;
    esac

    ####################################################################
    step "Verifying the install"
    if version=$("$LAUNCHER" --version 2>/dev/null); then
        ok "suplemon $version responds"
    else
        die "The launcher did not run. Try: $LAUNCHER --version"
    fi

    printf '\n%sDone.%s\n' "$G$B" "$N"
    info "Run it with:  suplemon [file]"
    [ -L "$SHORTCUT" ] && info "          or:  se [file]"
    info "Press F1 inside the editor for help, Ctrl+Q to quit."

    # Optional, and deliberately not done for you: this script installs
    # entirely inside $HOME and never asks for a password. sudo replaces
    # PATH with secure_path, which excludes ~/.local/bin but includes
    # /usr/local/bin, so a copy there is what makes "sudo suplemon" work
    # by name rather than by full path.
    # Symlinks rather than copies, so they keep tracking the launcher when
    # this script is re-run. Never suggest clobbering an "se" that is not
    # ours: a stream editor of that name exists and could be installed.
    usrlocal_ok=1
    for f in "$SYS_BIN_DIR/suplemon" "$SYS_BIN_DIR/se"; do
        if [ -e "$f" ] || [ -L "$f" ]; then
            if ! grep -q 'SUPLEMON_HOME' "$f" 2>/dev/null &&
               [ "$(readlink "$f" 2>/dev/null)" != "$LAUNCHER" ]; then
                warn "$f exists and is not ours; leaving it alone"
                usrlocal_ok=0
            fi
        fi
    done
    if [ "$usrlocal_ok" = "1" ] && { [ ! -e "$SYS_BIN_DIR/suplemon" ] || [ ! -e "$SYS_BIN_DIR/se" ]; }; then
        printf '\n%sOptional.%s sudo replaces PATH with its own secure_path, which\n' "$B" "$N"
        info "excludes $BIN_DIR. To use it with sudo, link the launcher"
        info "into $SYS_BIN_DIR. This is the only step that needs a password:"
        printf '\n        %ssudo ln -sf %s %s/suplemon && sudo ln -sf %s %s/se%s\n' \
            "$B" "$LAUNCHER" "$SYS_BIN_DIR" "$LAUNCHER" "$SYS_BIN_DIR" "$N"
        info "Links, not copies, so re-running this script keeps them current."
        info "They run your source tree, so keep them to machines you alone use."
    elif [ "$usrlocal_ok" = "1" ]; then
        ok "Linked into $SYS_BIN_DIR, so sudo can find it"
    fi

    # Anything the user still has to do goes last, so it is the final thing
    # on screen rather than something scrolled away by later output. This
    # script cannot set PATH for you: it runs in its own process, and a
    # child process cannot change its parent shell's environment.
    if [ "$needs_export" = "1" ]; then
        printf '\n%s%sOne more step.%s %s is not on this shell'"'"'s PATH yet.\n' \
            "$Y" "$B" "$N" "$BIN_DIR"
        info "New terminals will pick it up automatically. For this one, run:"
        printf '\n        %sexport PATH="$HOME/.local/bin:$PATH"%s\n' "$B" "$N"
        info "Or start it by full path right now:  $LAUNCHER"
    elif [ "$needs_export" = "2" ]; then
        printf '\n%s%sOne more step.%s Your shell is fish. Run this once:\n' \
            "$Y" "$B" "$N"
        printf '\n        %sfish_add_path $HOME/.local/bin%s\n' "$B" "$N"
        info "Or start it by full path right now:  $LAUNCHER"
    fi
    printf '\n'
}

main "$@"
