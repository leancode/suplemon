Change Log
==========


## v0.3.0 (unreleased) - leancode fork

This fork picks up where the upstream repo stopped in 2020. Every change
below is verified against Python 3.11 and 3.13.

**Runs on current Python**

- Replaced the `imp` module, removed in Python 3.12, with `importlib`.
  Without this Suplemon would not start at all on 3.12 or later.
- Stopped calling `curses.endwin()` twice, which made every clean exit end
  in `_curses.error` on current ncurses.
- Removed the Python 2 scaffolding, and the version guard that would have
  silently stopped encoding output on a future Python 4.
- Replaced all 54 bare excepts with the exceptions actually expected, so
  KeyboardInterrupt and SystemExit are no longer swallowed.

**Fixed**

- Opening a large file took minutes. The autocomplete word list used a
  linear membership test, making it quadratic in file size. A 7 MB file
  went from over a minute to under a second. (upstream #274)
- Any prompt crashed with `'NoneType' object has no attribute 'getmaxyx'`
  when the bottom bar was hidden. (upstream #269)
- Extensions with no matching Pygments lexer alias, notably `.h`, `.hpp`,
  `.kt` and `.svh`, got no syntax highlighting. (upstream #263)
- Key bindings deleted from the user keymap stayed active until restart.
  (upstream #266)
- Auto indent produced no indentation on tab indented files, and the
  comment module converted tab indentation to spaces.
- Undoing, editing, then undoing again skipped a step.
- Files are read and written in the configured `default_encoding` instead
  of whatever the locale happened to be.
- `Config.store()` opened the file read only and wrote to the wrong path.
- A bare `~` was treated as a filename rather than the home directory.

**Changed**

- Help moved to <kbd>F1</kbd>, save as to <kbd>F3</kbd>. <kbd>Ctrl</kbd> +
  <kbd>H</kbd> still works where the terminal allows it, which excludes
  every terminal whose backspace key sends `^H`, FreeBSD's included.
- 256 colour support is detected by palette size rather than
  `can_change_color()`, which had been dropping tmux, screen, konsole and
  PuTTY down to 8 colours. (upstream #253)
- The line number colour is configurable, and readable by default.
- A config file is written on first run instead of only complaining that
  none exists.
- `debug` defaults to off, and when on, the log dump explains itself.
- Line endings are hidden at startup with a visible default character, so
  <kbd>F10</kbd> does something.
- Clipboard support for Wayland, WSL, Termux and Windows. (upstream #272)
- New `--log-level` option. (upstream #265)

**Documentation**

- The help documents how selection works, which keys exist, and the ones
  that do nothing. (upstream #225, #264)
- README and dependency docs describe reality: `wcwidth` is required,
  Python 3.8 is the floor, and the install instructions work on a
  PEP 668 distribution.

**Tooling**

- Travis replaced with GitHub Actions on current Python versions.
- Packaging metadata filled in; `release.sh` uses `build` and `twine`.


## [v0.2.1](https://github.com/richrd/suplemon/tree/0.2.1) (2019-08-29) compared to previous master branch.
[Full Changelog](https://github.com/richrd/suplemon/compare/0.2.0...0.2.1)

**Fixed bugs:**

- Fix a bug introduced by 0.2.0, where key bindings weren't set up if the user key config file was missing.

## [v0.2.0](https://github.com/richrd/suplemon/tree/0.2.0) (2019-06-16) compared to previous master branch.
[Full Changelog](https://github.com/richrd/suplemon/compare/0.1.65...0.2.0)

**Fixed bugs:**

- Fix not using the delta argument in the cursor move_up method.
- Fix issue where mouse events in prompts could crash suplemon #247
- Fix not being able to override default keys with user key bindings

**Implemented enhancements:**

- Allow help to be toggled with the help shortcut. Credit @caph1993
- Allow opening files at specific row and column from command line.


## [v0.1.65](https://github.com/richrd/suplemon/tree/0.1.65) (2019-03-11) compared to previous master branch.
[Full Changelog](https://github.com/richrd/suplemon/compare/0.1.64...0.1.65)

**Fixed bugs:**

- Merge all the default config into user config. Credit @Consolatis
- Fix diff command highlighting
- Add shift+pageup and shift+pagedown bindings
- Reuse existing windows on resize. Credit @Consolatis
- Replace link to gitter chat with freenode webchat. Credit @Consolatis
- Merge default module configs into user config. Credit @Consolatis
- Use daemon mode for lint thread to fix shutdown delay. Credit @Consolatis
- Simple xterm-256color imitation for curses. Credit @abl

**Implemented enhancements:**

- Allow line number padding using spaces instead of zeros. Credit @Consolatis
- Highlight current line(s) Credit @Consolatis
- Add crypt module for encrypting buffers with a password


## [v0.1.64](https://github.com/richrd/suplemon/tree/0.1.64) (2017-12-17) compared to previous master branch.
[Full Changelog](https://github.com/richrd/suplemon/compare/0.1.63...0.1.64)

**Implemented enhancements:**

- Add bulk_delete and sort_lines commands.
- Lots of code style fixes and improvements. Credit @Gnewbee
- Add xclip support for system clipboard. Credit @LChris314
- Added command docs to readme and help.


## [v0.1.63](https://github.com/richrd/suplemon/tree/0.1.63) (2017-10-05) compared to previous master branch.
[Full Changelog](https://github.com/richrd/suplemon/compare/0.1.62...0.1.63)

**Implemented enhancements:**

- Add autocomplete to run command prompt (fixes #171)
- Increase battery status polling time to 60 sec (previously 10 sec)
- Change the top bar suplemon icon to a fancy unicode lemon.
- Add paste mode for better pasting over SSH (disables auto indentation)

**Fixed bugs:**

- Keep top bar statuses of modules in alphabetical order based on module name. (fixes #57)
- Prevent restoring file state if file has changed since last time (fixes #198)


## [v0.1.62](https://github.com/richrd/suplemon/tree/0.1.62) (2017-09-25) compared to previous master branch.
[Full Changelog](https://github.com/richrd/suplemon/compare/0.1.61...0.1.62)

**Fixed bugs:**

- Fixed and re-enabled fancy unicode symbols.
- Fixed typos in default configuration. Credit @1fabunicorn (#192)
- Fixed error message when loading valid but empty config file (Fixes #196).

**Implemented enhancements:**

- Add ctrl+t shortcut for trimming whitespace


## [v0.1.61](https://github.com/richrd/suplemon/tree/0.1.61) (2017-05-29) compared to previous master branch.
[Full Changelog](https://github.com/richrd/suplemon/compare/0.1.60...0.1.61)

**Fixed bugs:**

- Disable fancy unicode symbols by default. Caused problems on some terminals.


## [v0.1.60](https://github.com/richrd/suplemon/tree/0.1.60) (2017-03-23) compared to previous master branch.
[Full Changelog](https://github.com/richrd/suplemon/compare/0.1.59...0.1.60)

**Implemented enhancements:**

- Add support for the MacOS native pasteboard via pbcopy/pbpaste. Credit @abl
- Added shift+tab for going backwards when autocompleting files.
- Added F keys with modifiers and fixed some ctrl+shift keybindings.

**Fixed bugs:**

- Broader error handling in hostname module.
- Don't print log message when opening file that doesn't exist.


## [v0.1.59](https://github.com/richrd/suplemon/tree/0.1.59) (2017-02-16) compared to previous master branch.
[Full Changelog](https://github.com/richrd/suplemon/compare/0.1.58...0.1.59)

**Implemented enhancements:**

- Added pygments as a dependency. 


**Fixed bugs:**

- Added error handling to hostname module should it fail.


## [v0.1.58](https://github.com/richrd/suplemon/tree/0.1.58) (2016-12-01) compared to previous master branch.
[Full Changelog](https://github.com/richrd/suplemon/compare/0.1.57...0.1.58)

**Fixed bugs:**

- Fixed tests by using newer flake8.
- Treat .ts files the same as .js so (un)commenting .ts files works.


## [v0.1.57](https://github.com/richrd/suplemon/tree/0.1.57) (2016-11-01) compared to previous master branch.
[Full Changelog](https://github.com/richrd/suplemon/compare/0.1.56...0.1.57)

**Implemented enhancements:**
- Show all special unicode whitespace characters when "show_white_space" is set to true. This helps detecting unwanted characters in files.
- Now the mouse wheel works the same way in normal mode and mouse mode.

**Fixed bugs:**

- Fixed weird crash when pasting lots of text into prompts (like the find prompt etc)
- Fixed false matches in diff highlighting.
- Fixed inability to open empty files.
- Fixed adding cursors via mouse click when the view is horizontally scrolled.
- Fixed inputting various special characters that were ignored in some cases on Python3.


## [v0.1.56](https://github.com/richrd/suplemon/tree/0.1.56) (2016-08-01) compared to previous master branch.
[Full Changelog](https://github.com/richrd/suplemon/compare/0.1.55...0.1.56)

**Implemented enhancements:**

- New feature: Ability to use hard tabs instead of spaces via the boolean option 'hard_tabs'.
- New feature: Save all files by running the ´save_all´ command.
- New feature: Linter now shows PHP syntax errors (if PHP is installed).
- New module: New `diff` command for comaring current edits to the file on disk.
- New module: Show machine hostname in bottom status bar.
- Enhanced Go To feature: If no file name begins with the search string, also match file names that contain the search string at any position.
- Module status info is now shown on the left of core info in the bottom status bar.
- More supported key bindings.
- Other light code improvements.

**Fixed bugs:**

- Prevented multiple warnings about missing pygments.
- Reload user keymap when it's changed in the editor.
- Prioritize user key bindings over defaults. [\#163](https://github.com/richrd/suplemon/issues/163)
- Reworked key handling to support more bindings (like `ctrl+enter` on some terminals).
- Normalize modifier key order in keymaps so that they are matched correctly.
- Properly set the internal file path when saving a file under a new name.

## [v0.1.55](https://github.com/richrd/suplemon/tree/0.1.55) (2016-08-01) compared to previous master branch.
[Full Changelog](https://github.com/richrd/suplemon/compare/0.1.54...0.1.55)

**Implemented enhancements:**

- Faster loading when linting lots of files

- Use `invisibles` setting in TextMate themes [\#77](https://github.com/richrd/suplemon/issues/77)

**Fixed bugs:**

- Show key legend based on config instead of static defaults [\#157](https://github.com/richrd/suplemon/issues/157)


## [v0.1.54](https://github.com/richrd/suplemon/tree/0.1.54) (2016-07-30) compared to previous master branch.
[Full Changelog](https://github.com/richrd/suplemon/compare/0.1.53...0.1.54)

**Implemented enhancements:**

- Autocomplete in open/save dialogs

**Fixed bugs:**

- Fixed showing unwritable marker when saving file in a writable location


## [v0.1.32](https://github.com/richrd/suplemon/tree/0.1.32) (2015-08-12) compared to previous master branch.
[Full Changelog](https://github.com/richrd/suplemon/compare/0.1.31...0.1.32)

**Implemented enhancements:**

- Use Sphinx notation for documenting parameters/return values etc [\#54](https://github.com/richrd/suplemon/issues/54)
- Pygments syntax highlighting [\#52](https://github.com/richrd/suplemon/issues/52)
- Make jumping between words also jump to next or previous line when applicable. [\#48](https://github.com/richrd/suplemon/issues/48)
- Retain cursor x coordinate when moving vertically. [\#24](https://github.com/richrd/suplemon/issues/24)
- Add line number coloring to linelighters. [\#23](https://github.com/richrd/suplemon/issues/23)
- Native clipboard support [\#73](https://github.com/richrd/suplemon/issues/73)
- Installing system-wide [\#75](https://github.com/richrd/suplemon/issues/75)
- Added a changelog. The new version is much more mature than before, and there are a lot of changes. That's why this is the first changelog (that should have existed long before)

**Closed issues:**

- Auto hide keyboard shortcuts from status bar  [\#70](https://github.com/richrd/suplemon/issues/70)

**Fixed bugs:**

- Using delete at the end of multiple lines behaves incorrectly [\#74](https://github.com/richrd/suplemon/issues/74)

**Merged pull requests:**

- Implemented jumping between lines. Fixes \#48. [\#72](https://github.com/richrd/suplemon/pull/72) ([richrd](https://github.com/richrd))
- Pygments-based highlighting [\#68](https://github.com/richrd/suplemon/pull/68) ([Jimx-](https://github.com/Jimx-))
