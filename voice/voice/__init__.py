import os
import os.path
import zipfile
import sys
import time

from _voice import *

last_prompt_spoken=''
last_prompt_is_priority=False
disable_sayagain_one_time=False

# Event Type constants for adding Callbacks in Catalyst code.
EVT_SCAN_CB = 1
EVT_BUTTON_CB = 2
EVT_PRINT_COMPLETE_CB = 3
EVT_LOCALE_CHANGED_CB = 4
EVT_TRAINING_DONE_CB = 5
EVT_TERMINAL_WAKEUP_CB = 6
EVT_TERMINAL_SLEEP_CB = 7
EVT_OPERATOR_LOAD_CB = 8

# Create any prohibitor objects we might need
from .prohibitor import Prohibitor
task_unload_prohibitor = Prohibitor()

# Hoist public components into the namespace
from .dialog_objects import Dialog, Node, Link

class _DecodedZipExtFile(object):
    """Wrapper for ZipExtFile that behaves like a file opened in
    read-only, text mode.
    """

    def __init__(self, f, encoding='utf-8'):
        self.wrapped = f
        self.encoding = encoding
        self.mode = 'r'  # force the stream to be read-only, text mode

    def __getattr__(self, name):
        """Delegate most attributes to the wrapped object."""
        return getattr(self.wrapped, name)

    def readline(self, size=-1):
        """Call the wrapped object's readline and decode the result."""
        return self.wrapped.readline(size).decode(self.encoding)

    def readlines(self, sizehint=-1):
        """Call the wrapped object's readlines and decode the result."""
        return [line.decode(self.encoding)
                for line in self.wrapped.readlines(sizehint)]

    def read(self, size=None):
        """Call the wrapped object's read and decode the result."""
        return self.wrapped.read(size).decode(self.encoding)

    def __iter__(self):
        return self

    def __next__(self):
        nextline = self.readline()
        if not nextline:
            raise StopIteration()
        return nextline

def current_time():
    if sys.platform == "win32":
        return time.clock()
    else:
        return time.time()

def open_vad_resource (name, mode = 'r', encoding='utf-8'):
    """Open a resource file within the VAD for currently running voice
    application.
    """
    vad_path = get_vad_path()
    # remove 'task.vad' from the file pathname
    vad_path = vad_path[0:len(vad_path)-8]
    # always open the resource file in binary mode, that way we can
    # ensure proper unicode conversion for text files
    contents = open(os.path.join(vad_path, 'resources/', name), 'rb')
    if 'b' in mode:
        return contents
    return _DecodedZipExtFile(contents, encoding)
