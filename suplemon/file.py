# -*- encoding: utf-8
"""
File object for storing an opened file and editor.
"""

import os
import time
import logging

from .helpers import parse_path


class File:
    def __init__(self, app=None):
        self.app = app
        self.logger = logging.getLogger(__name__)
        self.name = ""
        self.fpath = ""
        self.data = None
        self.read_only = False  # Currently unused
        self.last_save = None  # Time of last save
        self.opened = time.time()  # Time of last open
        self.editor = None
        self.writable = True
        self.is_help = False

    def _path(self):
        """Get the full path of the file."""
        return os.path.join(self.fpath, self.name)

    def get_encoding(self):
        """Get the encoding to read and write this file with.

        Comes from the editor's default_encoding setting. Without this the
        files were opened with whatever the locale happened to be, so the
        setting did nothing and a non UTF-8 locale mangled the contents.

        :return: Name of the encoding to use.
        :rtype: str
        """
        default = "utf-8"
        if self.app is None:
            return default
        try:
            return self.app.config["editor"]["default_encoding"] or default
        except (KeyError, TypeError):
            return default

    def path(self):
        """Get the full path of the file."""
        # TODO: deprecate in favour of get_path()
        return self._path()

    def get_name(self):
        """Get the file name."""
        return self.name

    def get_path(self):
        """Get the full path of the file."""
        return self._path()

    def get_extension(self):
        parts = self.name.split(".")
        if len(parts) < 2:
            return ""
        return parts[-1]

    def get_editor(self):
        """Get the associated editor."""
        return self.editor

    def set_name(self, name):
        """Set the file name."""
        # TODO: sanitize
        self.name = name
        self.update_editor_extension()

    def set_path(self, path):
        """Set the file path. Relative paths are sanitized."""
        self.fpath, self.name = parse_path(path)
        self.update_editor_extension()

    def set_data(self, data):
        """Set the file data and apply to editor if it exists."""
        self.data = data
        if self.editor:
            self.editor.set_data(data)

    def set_editor(self, editor):
        """The editor instance set its file extension."""
        self.editor = editor
        self.update_editor_extension()

    def on_load(self):
        """Does checks after file is loaded."""
        self.writable = os.access(self._path(), os.W_OK)
        if not self.writable:
            self.logger.info("File not writable.")

    def update_editor_extension(self):
        """Set the editor file extension from the current file name."""
        if not self.editor:
            return False
        ext = self.get_extension()
        if len(ext) >= 1:
            self.editor.set_file_extension(ext)

    def save(self):
        """Write the editor data to file."""
        data = self.editor.get_data()
        try:
            with open(self._path(), "w", encoding=self.get_encoding()) as f:
                f.write(data)
        except (OSError, LookupError, UnicodeError):
            self.logger.exception('Failed writing file "{file}"'.format(file=self._path()))
            return False
        self.data = data
        self.last_save = time.time()
        self.writable = os.access(self._path(), os.W_OK)
        return True

    def load(self, read=True):
        """Try to read the actual file and load the data into the editor instance."""
        if not read:
            return True
        path = self._path()
        if not os.path.isfile(path):
            self.logger.debug("Given path isn't a file.")
            return False
        data = self._read(path)
        if data is False:
            return False
        self.data = data
        self.editor.set_data(data)
        self.on_load()
        return True

    def _read(self, path):
        data = self._read_text(path)
        if data is False:
            self.logger.warning("Normal file read failed.")
            data = self._read_binary(path)
        if data is False:
            self.logger.warning("Fallback file read failed.")
            return False
        return data

    def _read_text(self, file):
        # Read text file
        try:
            with open(self._path(), encoding=self.get_encoding()) as f:
                return f.read()
        except (OSError, LookupError, UnicodeDecodeError):
            self.logger.exception('Failed reading file "{file}"'.format(file=file))
            return False

    def _read_binary(self, file):
        # Read binary file and try to autodetect encoding
        try:
            f = open(self._path(), "rb")
            data = f.read()
            f.close()
            import chardet
            detection = chardet.detect(data)
            charenc = detection["encoding"]
            if charenc is None:
                self.logger.warning("Failed to detect file encoding.")
                return False
            self.logger.info("Trying to decode with encoding '{0}'".format(charenc))
            return data.decode(charenc)
        except Exception:
            self.logger.warning("Failed reading binary file!", exc_info=True)
        return False

    def reload(self):
        """Reload file data."""
        return self.load()

    def is_changed(self):
        """Check if the editor data is different from the file."""
        return self.editor.get_data() != self.data

    def is_changed_on_disk(self):
        path = self._path()
        if os.path.isfile(path):
            data = self._read(path)
            if data != self.data:
                return True
        return False

    def is_writable(self):
        """Check if the file is writable."""
        return self.writable
