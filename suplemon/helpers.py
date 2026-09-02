# -*- encoding: utf-8
"""
Various helper constants and functions.
"""

import os
import re
import sys
import time
import traceback


def curr_time():
    """Current time in %H:%M"""
    return time.strftime("%H:%M")


def curr_time_sec():
    """Current time in %H:%M:%S"""
    return time.strftime("%H:%M:%S")


def multisplit(data, delimiters):
    pattern = "|".join(map(re.escape, delimiters))
    return re.split(pattern, data)


def get_error_info():
    """Return info about last error."""
    msg = "{0}\n{1}".format(str(traceback.format_exc()), str(sys.exc_info()))
    return msg


def get_string_between(start, stop, s):
    """Search string for a substring between two delimeters. False if not found."""
    i1 = s.find(start)
    if i1 == -1:
        return False
    s = s[i1 + len(start):]
    i2 = s.find(stop)
    if i2 == -1:
        return False
    s = s[:i2]
    return s


def whitespace(line):
    """Return index of first non whitespace character on a line.

    Tabs count as whitespace. Only spaces used to, which meant tab indented
    files behaved as though they had no indentation at all.
    """
    i = 0
    for char in str(line):
        if char not in " \t":
            break
        i += 1
    return i


def leading_whitespace(line):
    """Return the indentation of a line, as written.

    Use this instead of whitespace() when the indentation is going to be
    reproduced, so that tabs stay tabs and spaces stay spaces.
    """
    line = str(line)
    return line[:whitespace(line)]


def parse_path(path):
    """Parse a relative path and return full directory and filename as a tuple.

    expanduser handles a bare "~" as well as "~/...", which the previous
    manual prefix check did not: "~" on its own was treated as a filename
    in the current directory.
    """
    path = os.path.expanduser(path)
    ab = os.path.abspath(path)
    parts = os.path.split(ab)
    return parts


def get_filename_cursor_pos(name):
    default = {
        "name": name,
        "row": 0,
        "col": 0,
    }

    m = re.match(r"(.*?):(\d+):?(\d+)?", name)

    if not m:
        return default

    groups = m.groups()
    if not groups[0]:
        return default

    return {
        "name": groups[0],
        "row": abs(int(groups[1])-1) if groups[1] else 0,
        "col": abs(int(groups[2])-1) if groups[2] else 0,
    }
