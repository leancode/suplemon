Suplemon :lemon:
========

[![test](https://github.com/leancode/suplemon/actions/workflows/test.yml/badge.svg)](https://github.com/leancode/suplemon/actions/workflows/test.yml)

          ___________   _________  ___     ______________________________   ___
         /  _____/  /  /  /  _   \/  /\   /  ______/        /  ___   /   | /  /\
        /  /____/  /  /  /  /_/  /  / /  /  /_____/  /  /  /  /  /  /    |/  / /
       /____   /  /  /  /  _____/  / /  /  ______/  /  /  /  /  /  /  /|    / /
      _____/  /  /__/  /  /\___/  /____/  /_____/  /  /  /  /__/  /  / |   / /
     /_______/\_______/__/ /  /_______/________/__/__/__/________/__/ /|__/ /
     \_______\ \______\__\/   \_______\________\__\__\__\________\__\/ \__\/

              Remedying the pain of command line editing since 2014


Suplemon is a modern, powerful and intuitive console text editor with multi cursor support.
Suplemon replicates Sublime Text style functionality in the terminal with the ease of use of Nano.
https://github.com/leancode/suplemon


![Suplemon in action](https://i.imgur.com/pdKvKsN.gif)

## About this fork

This is an actively maintained fork of [richrd/suplemon](https://github.com/richrd/suplemon).

The original is a genuinely good editor and none of the design here is ours.
Upstream simply stopped: the last commit to `master` landed in January 2021,
the `dev` branch in June 2020, and 25 issues and 5 pull requests are still
open, some since 2016. Suplemon had also stopped running altogether on
Python 3.12 and newer, which is what prompted the fork.

Since then this fork has:

 * restored it on current Python, including 3.13
 * fixed the upstream bugs that were reported but never merged, among them
   large files taking minutes to open, a crash in every prompt when the
   bottom bar was hidden, and missing syntax highlighting for several file
   extensions
 * adopted the useful parts of the unmerged upstream pull requests, including
   the maintainer's own unreleased v0.2.9 work
 * fixed things nobody had reported, such as auto indent losing tab
   indentation, and modified keys like <kbd>Alt</kbd> + <kbd>Left</kbd>
   silently doing the wrong thing
 * added an installer, CI on current Python versions, and rather more
   documentation

See the [CHANGELOG](CHANGELOG.md) for the details.

### Credit

Suplemon was written by **Richard Lewis** ([richrd](https://github.com/richrd))
and its contributors, and is MIT licensed. The editor, its multi cursor model
and its interface are all their work. Thank you for building something worth
keeping alive.

Thanks also to the people whose unmerged pull requests were adopted here:
[bagage](https://github.com/bagage) and
[joshcangit](https://github.com/joshcangit).

If upstream ever picks development back up, the changes here are deliberately
kept in small, self contained commits so they can be offered back.

## Features
 * Proper multi cursor editing, as in Sublime Text
 * Syntax highlighting with Text Mate themes
 * Autocomplete (based on words in the files that are open)
 * Easy Undo/Redo (Ctrl + Z, Ctrl + Y)
 * Copy & Paste, with multi line support (and native clipboard support on X11 / Unix and Mac OS)
 * Multiple files in tabs
 * Powerful Go To feature for jumping to files and lines
 * Find, Find next and Find all (Ctrl + F, Ctrl + D, Ctrl + A)
 * Custom keyboard shortcuts (and easy-to-use defaults)
 * Mouse support
 * Restores cursor and scroll positions when reopenning files
 * Extensions (easy to write your own)
 * Lots more...


## Caveats
 * No built in selections (regions). Copy and cut act on whole lines that have a cursor on them; see the "Selecting text" section of the built in help (<kbd>F1</kbd>). To copy part of a line, select it with your mouse and use your terminal's own copy shortcut, usually <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>C</kbd>

## Try it!

You can clone the repo and run Suplemon from source, or install it. Running
from source needs `wcwidth`; `pygments` is optional but gives you proper
syntax highlighting instead of the simpler line based colouring.

    git clone https://github.com/leancode/suplemon.git
    cd suplemon
    python3 -m venv venv
    ./venv/bin/pip install wcwidth pygments
    ./venv/bin/python suplemon.py

### Installation

One line, no sudo, everything under `~/.local`:

    curl -fsSL https://raw.githubusercontent.com/leancode/suplemon/master/install.sh | sh

It checks your platform and Python version, clones or updates the source in
`~/.local/src/suplemon`, builds a virtualenv, writes a launcher to
`~/.local/bin/suplemon`, adds an `se` shortcut if that name is free, and puts
`~/.local/bin` on your `PATH` if it isn't already. Re-run it any time to
update. Read it first if you'd rather not pipe a script into a shell:
[install.sh](install.sh).

To remove it again:

    curl -fsSL https://raw.githubusercontent.com/leancode/suplemon/master/uninstall.sh | sh

That removes the launchers and `~/.local/src/suplemon`, and keeps
`~/.local/bin` and your config. Add `--purge` to remove the config too, or
`--dry-run` to see what it would do first. With the pipe those go after
`sh -s --`, for example `... | sh -s -- --dry-run`.

### Installing as a package

The tidiest way is [pipx](https://pipx.pypa.io/), which puts Suplemon and its
dependencies in their own environment and still gives you a `suplemon` command:

    pipx install suplemon

To install from a clone of the repo:

    pipx install .

Plain `pip install` works too, but install it into a virtual environment
rather than system wide. Most current distributions ship a Python marked as
externally managed (PEP 668) and will refuse `sudo pip install` outright.

### Usage

    suplemon # New file in the current directory
    suplemon [filename]... # Open one or more files
    suplemon [filename:row:col]... # Open one or more files at a specific row or column (optional)


### Notes
 - **Python 3.8 or higher.** Python 2 is not supported.
 - *The master branch is considered stable.*
 - *Tested on Linux and FreeBSD.*

`wcwidth` is required. `pygments` is optional and recommended; see
[docs/optional-dependencies.md](docs/optional-dependencies.md) for the rest.

### Optional dependencies

 * Pygments
 > For support for syntax highlighting over 300 languages.

 * Flake8
 > For showing linting for Python files.

 * xsel or xclip
 > For system clipboard support on X Window (Linux).

 * pbcopy / pbpaste
 > For system clipboard support on Mac OS.

 See [docs/optional-dependencies.md][] for installation instructions.

 [docs/optional-dependencies.md]: docs/optional-dependencies.md

## Description
Suplemon is an intuitive command line text editor. It supports multiple cursors out of the box.
It is as easy as nano, and has much of the power of Sublime Text. It also supports extensions
to allow all kinds of customizations. To get more help hit ```Ctrl + H``` in the editor.
Suplemon is licensed under the MIT license.

## Configuration

### Main Config
The suplemon config file is stored at ```~/.config/suplemon/suplemon-config.json```.

The best way to edit it is to run the ```config``` command (Run commands via ```Ctrl+E```).
That way Suplemon will automatically reload the configuration when you save the file.
To view the default configuration and see what options are available run ```config defaults``` via ```Ctrl+E```.


### Keymap Config

Below are the default key mappings used in suplemon. They can be edited by running the ```keymap``` command.
To view the default keymap file run ```keymap default```

 * <kbd>Ctrl</kbd> + <kbd>Q</kbd>
   > Exit

 * <kbd>Ctrl</kbd> + <kbd>W</kbd>
   > Close file or tab

 * <kbd>Ctrl</kbd> + <kbd>C</kbd>
   > Copy line(s) to buffer

 * <kbd>Ctrl</kbd> + <kbd>X</kbd>
   > Cut line(s) to buffer

 * <kbd>Ctrl</kbd> + <kbd>V</kbd>
   > Insert buffer

 * <kbd>Ctrl</kbd> + <kbd>K</kbd>
   > Duplicate line

 * <kbd>Ctrl</kbd> + <kbd>G</kbd>
   > Go to line number or file (type the beginning of a filename to switch to it).
   > You can also use 'filena:42' to go to line 42 in filename.py etc.

 * <kbd>Ctrl</kbd> + <kbd>F</kbd>
   > Search for a string or regular expression (configurable)

 * <kbd>Ctrl</kbd> + <kbd>D</kbd>
   > Search for next occurrence or find the word the cursor is on. Adds a new cursor at each new occurrence.

 * <kbd>Ctrl</kbd> + <kbd>T</kbd>
   > Trim whitespace

 * <kbd>Alt</kbd> + <kbd>Arrow Key</kbd>
   > Add new cursor in arrow direction

 * <kbd>Ctrl</kbd> + <kbd>Left / Right</kbd>
   > Jump to previous or next word or line

 * <kbd>ESC</kbd>
   > Revert to a single cursor / Cancel input prompt

 * <kbd>Alt</kbd> + <kbd>Page Up</kbd>
   > Move line(s) up

 * <kbd>Alt</kbd> + <kbd>Page Down</kbd>
   > Move line(s) down

 * <kbd>Ctrl</kbd> + <kbd>S</kbd>
   > Save current file

 * <kbd>F1</kbd>
   > Save file with new name

 * <kbd>F2</kbd>
   > Reload current file

 * <kbd>Ctrl</kbd> + <kbd>O</kbd>
   > Open file

 * <kbd>Ctrl</kbd> + <kbd>W</kbd>
   > Close file

 * <kbd>Ctrl</kbd> + <kbd>Page Up</kbd>
   > Switch to next file

 * <kbd>Ctrl</kbd> + <kbd>Page Down</kbd>
   > Switch to previous file

 * <kbd>Ctrl</kbd> + <kbd>E</kbd>
   > Run a command.

 * <kbd>Ctrl</kbd> + <kbd>Z</kbd> and <kbd>F5</kbd>
   > Undo

 * <kbd>Ctrl</kbd> + <kbd>Y</kbd> and <kbd>F6</kbd>
   > Redo

 * <kbd>F7</kbd>
   > Toggle visible whitespace

 * <kbd>F8</kbd>
   > Toggle mouse mode

 * <kbd>F9</kbd>
   > Toggle line numbers

 * <kbd>F11</kbd>
   > Toggle full screen

## Mouse shortcuts

 * Left Click
   > Set cursor at mouse position. Reverts to a single cursor.

 * Right Click
   > Add a cursor at mouse position.

 * Scroll Wheel Up / Down
   > Scroll up & down.

## Commands

Suplemon has various add-ons that implement extra features.
The commands can be run with <kbd>Ctrl</kbd> + <kbd>E</kbd> and the prompt has autocomplete to make running them faster.
The available commands and their descriptions are:

 * autocomplete

    A simple autocompletion module.

    This adds autocomplete support for the tab key. It uses a word
    list scanned from all open files for completions. By default it suggests
    the shortest possible match. If there are no matches, the tab action is
    run normally.

 * autodocstring

    Simple module for adding docstring placeholders.

    This module is intended to generate docstrings for Python functions.
    It adds placeholders for descriptions, arguments and return data.
    Function arguments are crudely parsed from the function definition
    and return statements are scanned from the function body.

 * bulk_delete

    Bulk delete lines and characters.
    Asks what direction to delete in by default.

    Add 'up' to delete lines above highest cursor.
    Add 'down' to delete lines below lowest cursor.
    Add 'left' to delete characters to the left of all cursors.
    Add 'right' to delete characters to the right of all cursors.

 * comment

    Toggle line commenting based on current file syntax.

 * config

    Shortcut for openning the config files.

 * diff

    View a diff of the current file compared to it's on disk version.

 * eval

    Evaluate a python expression and show the result in the status bar.

    If no expression is provided the current line(s) are evaluated and
    replaced with the evaluation result.

 * keymap

    Shortcut to openning the keymap config file.

 * linter

    Linter for suplemon.

 * lower

    Transform current lines to lower case.

 * lstrip

    Trim whitespace from beginning of current lines.

 * paste

    Toggle paste mode (helpful when pasting over SSH if auto indent is enabled)

 * reload

    Reload all add-on modules.

 * replace_all

    Replace all occurrences in all files of given text with given replacement.

 * reverse

    Reverse text on current line(s).

 * rstrip

    Trim whitespace from the end of lines.

 * save

    Save the current file.

 * save_all

    Save all currently open files. Asks for confirmation.

 * sort_lines

    Sort current lines.

    Sorts alphabetically by default.
    Add 'length' to sort by length.
    Add 'reverse' to reverse the sorting.

 * strip

    Trim whitespace from start and end of lines.

 * tabstospaces

    Convert tab characters to spaces in the entire file.

 * toggle_whitespace

    Toggle visually showing whitespace.

 * upper

    Transform current lines to upper case.


## Support

If you experience problems, please submit a new issue.
If you have a question, need help, or just want to chat head over to the IRC channel #suplemon @ Freenode.
I'll be happy to chat with you, see you there!


## Development

If you are interested in contributing to Suplemon, development dependencies can be installed via:

    # For OS cleanliness, we recommend using `virtualenv` to prevent global contamination
    pip install -r requirements-dev.txt

After those are installed, tests can be run via:

    ./test.sh

PRs are very welcome and appreciated.
When making PRs make sure to set the target branch to `dev`. I only push to master when releasing new versions.


## Rationale
For many the command line is a different environment for text editing.
Most coders are familiar with GUI text editors and for many vi and emacs
have a too steep learning curve. For them (like for me) nano was the weapon of
choice. But nano feels clunky and it has its limitations. That's why
I wrote my own editor with built in multi cursor support to fix the situation.
Another reason is that developing Suplemon is simply fun to do.
