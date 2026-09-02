#!/usr/bin/env python3
# -*- encoding: utf-8
"""
Start a Suplemon instance in the current window
"""

import sys

try:
    import argparse
except ImportError:
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
    log_level = None
    if argparse:
        parser = argparse.ArgumentParser(description="Console text editor with multi cursor support")
        parser.add_argument("filenames", metavar="filename", type=str, nargs="*", help="files to open")
        parser.add_argument("--version", action="version", version=__version__)
        parser.add_argument("--config", type=str, help="configuration file path")
        parser.add_argument("--log-level", type=int, help="debug logging level")
        args = parser.parse_args()
        filenames = args.filenames
        config_file = args.config
        log_level = args.log_level
    else:
        # Python < 2.7 fallback
        filenames = sys.argv[1:]

    # Generate and start our application
    app = App(filenames=filenames, config_file=config_file, log_level=log_level)
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
