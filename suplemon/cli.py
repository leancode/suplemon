#!/usr/bin/env python3
# -*- encoding: utf-8
"""
Start a Suplemon instance in the current window
"""

import sys

try:
    import argparse
except:
    # Python < 2.7
    argparse = False

from .main import App, __version__


def print_debug_notice(app):
    """Explain the log that debug mode just printed, and how to turn it off.

    Without this the messages look like something went wrong, when they are
    only shown because debug mode asked for them.
    """
    print(
        "\nThe messages above are Suplemon's debug log, shown because debug mode is on.\n"
        'Set "debug": false in {0} to stop showing them.'.format(app.config.path()),
        file=sys.stderr
    )


def main():
    """Handle CLI invocation"""
    # Parse our CLI arguments
    config_file = None
    if argparse:
        parser = argparse.ArgumentParser(description="Console text editor with multi cursor support")
        parser.add_argument("filenames", metavar="filename", type=str, nargs="*", help="Files to load into Suplemon")
        parser.add_argument("--version", action="version", version=__version__)
        parser.add_argument("--config", type=str, help="Configuration file path.")
        args = parser.parse_args()
        filenames = args.filenames
        config_file = args.config
    else:
        # Python < 2.7 fallback
        filenames = sys.argv[1:]

    # Generate and start our application
    app = App(filenames=filenames, config_file=config_file)
    if app.init():
        app.run()

    # Output log info
    if app.debug:
        for logger_handler in app.logger.handlers:
            logger_handler.close()
        # Only explain the log if there was actually something to show
        if any(getattr(handler, "flushed_records", 0) for handler in app.logger.handlers):
            print_debug_notice(app)


if __name__ == "__main__":
    main()
