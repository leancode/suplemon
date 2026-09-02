Dependencies
============

Suplemon needs `wcwidth`. Everything below is optional: without any of it the
editor runs, but some features are switched off.

## wcwidth (required)

Used to measure how wide characters are on screen, so that wide and combining
characters line up. Suplemon will not start without it.

    pip install wcwidth

## Pygments

Adds proper syntax highlighting. Without it Suplemon falls back to the simpler
line based colouring in `suplemon/linelight/`, which covers fewer languages and
does not understand context.

    pip install pygments

More information: https://pygments.org/

## A clipboard tool

Lets copy and paste share text with other applications. Without one, copy and
paste still work inside Suplemon. The first of these that is found gets used:

| Tool | Where |
| --- | --- |
| `powershell.exe` | Windows and WSL |
| `wl-copy` / `wl-paste` (wl-clipboard) | Wayland |
| `xsel` | X11 |
| `pbcopy` / `pbpaste` | macOS |
| `xclip` | X11 |
| `termux-clipboard-get` / `-set` (termux-api) | Termux |

Install with your system package manager, for example:

    sudo apt install xsel          # X11
    sudo apt install wl-clipboard  # Wayland

## Flake8

Only needed to lint Suplemon itself, and by the `linter` module if you want it
to lint the Python file you are editing.

    pip install -r requirements-dev.txt

More information: https://flake8.readthedocs.io/
