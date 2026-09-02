# -*- encoding: utf-8

import os
import shutil
import subprocess
from platform import system

from suplemon.suplemon_module import Module

# Windows and WSL both reach the Windows clipboard through powershell
POWERSHELL = ["powershell.exe", "-noprofile", "-command"]


def is_wsl():
    """Detect WSL, where the Windows clipboard is reachable via powershell.exe."""
    if system() != "Linux" or not os.path.isfile("/proc/version"):
        return False
    try:
        with open("/proc/version") as f:
            return "microsoft" in f.read().lower()
    except OSError:
        return False


class SystemClipboard(Module):
    """Integrates the system clipboard with suplemon."""

    def init(self):
        self.init_logging(__name__)
        self.clipboard = self.detect_clipboard()
        if not self.clipboard:
            # No clipboard tool is normal on a headless or minimal system, and
            # suplemon's own copy/paste works regardless, so this isn't a
            # warning. Kept at debug level so it stays out of the way.
            self.logger.debug(
                "No system clipboard tool found. Install 'xsel', 'xclip', 'wl-clipboard', "
                "'pbcopy' or 'termux-api' to share the clipboard with other applications.")
            return False
        self.bind_event_before("insert", self.insert)
        self.bind_event_after("copy", self.copy)
        self.bind_event_after("cut", self.copy)

    def detect_clipboard(self):
        """Find the commands for the first usable clipboard tool.

        Ordered so the native mechanism wins where more than one is present:
        Windows and WSL first, then Wayland, then the X11 tools, then Termux.

        :return: Dict with "get" and "set" commands, or False if none found.
        """
        if (system() == "Windows" or is_wsl()) and shutil.which("powershell.exe"):
            return {
                "get": POWERSHELL + ["Get-Clipboard"],
                "set": POWERSHELL + ["Set-Clipboard"],
            }
        if os.environ.get("WAYLAND_DISPLAY") and shutil.which("wl-copy"):
            return {"get": ["wl-paste", "-n"], "set": ["wl-copy"]}
        if shutil.which("xsel"):
            return {"get": ["xsel", "-b"], "set": ["xsel", "-i", "-b"]}
        if shutil.which("pbcopy"):
            return {"get": ["pbpaste", "-Prefer", "txt"], "set": ["pbcopy"]}
        if shutil.which("xclip"):
            return {
                "get": ["xclip", "-selection", "clipboard", "-out"],
                "set": ["xclip", "-selection", "clipboard", "-in"],
            }
        if shutil.which("termux-clipboard-get"):
            return {"get": ["termux-clipboard-get"], "set": ["termux-clipboard-set"]}
        return False

    def copy(self, event):
        lines = self.app.get_editor().get_buffer()
        data = "\n".join([str(line) for line in lines])
        self.set_clipboard(data)

    def insert(self, event):
        data = self.get_clipboard()
        if data is False:
            # Reading the clipboard failed, leave suplemon's own buffer alone
            return
        lines = data.split("\n")
        self.app.get_editor().set_buffer(lines)

    def get_clipboard(self):
        try:
            return subprocess.check_output(self.clipboard["get"], universal_newlines=True)
        except (OSError, subprocess.CalledProcessError):
            return False

    def set_clipboard(self, data):
        try:
            p = subprocess.Popen(self.clipboard["set"], stdin=subprocess.PIPE)
            out, err = p.communicate(input=bytes(data, "utf-8"))
            return out
        except (OSError, subprocess.CalledProcessError):
            return False


module = {
    "class": SystemClipboard,
    "name": "system_clipboard",
}
