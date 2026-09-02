# -*- encoding: utf-8

import subprocess

from suplemon.suplemon_module import Module


class SystemClipboard(Module):
    """Integrates the system clipboard with suplemon."""

    def init(self):
        self.init_logging(__name__)
        if self.has_xsel_support():
            self.clipboard_type = "xsel"
        elif self.has_pb_support():
            self.clipboard_type = "pb"
        elif self.has_xclip_support():
            self.clipboard_type = "xclip"
        else:
            # No clipboard tool is normal on a headless or minimal system, and
            # suplemon's own copy/paste works regardless, so this isn't a
            # warning. Kept at debug level so it stays out of the way.
            self.logger.debug(
                "No system clipboard tool found. Install 'xsel', 'pbcopy' or 'xclip' to share the "
                "clipboard with other applications.")
            return False
        self.bind_event_before("insert", self.insert)
        self.bind_event_after("copy", self.copy)
        self.bind_event_after("cut", self.copy)

    def copy(self, event):
        lines = self.app.get_editor().get_buffer()
        data = "\n".join([str(line) for line in lines])
        self.set_clipboard(data)

    def insert(self, event):
        data = self.get_clipboard()
        lines = data.split("\n")
        self.app.get_editor().set_buffer(lines)

    def get_clipboard(self):
        try:
            if self.clipboard_type == "xsel":
                command = ["xsel", "-b"]
            elif self.clipboard_type == "pb":
                command = ["pbpaste", "-Prefer", "txt"]
            elif self.clipboard_type == "xclip":
                command = ["xclip", "-selection", "clipboard", "-out"]
            else:
                return False
            data = subprocess.check_output(command, universal_newlines=True)
            return data
        except:
            return False

    def set_clipboard(self, data):
        try:
            if self.clipboard_type == "xsel":
                command = ["xsel", "-i", "-b"]
            elif self.clipboard_type == "pb":
                command = ["pbcopy"]
            elif self.clipboard_type == "xclip":
                command = ["xclip", "-selection", "clipboard", "-in"]
            else:
                return False
            p = subprocess.Popen(command, stdin=subprocess.PIPE)
            out, err = p.communicate(input=bytes(data, "utf-8"))
            return out
        except:
            return False

    def has_pb_support(self):
        output = self.get_output(["which", "pbcopy"])
        return output

    def has_xsel_support(self):
        output = self.get_output(["xsel", "--version"])
        return output

    def has_xclip_support(self):
        output = self.get_output(["which", "xclip"])  # xclip -version outputs to stderr
        return output

    def get_output(self, cmd):
        try:
            process = subprocess.Popen(cmd, stdout=subprocess.PIPE)
        except (OSError, EnvironmentError):  # can't use FileNotFoundError in Python 2
            return False
        out, err = process.communicate()
        return out


module = {
    "class": SystemClipboard,
    "name": "system_clipboard",
}
