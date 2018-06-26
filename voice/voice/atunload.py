""" atunload.py: shell module to import _voice_atunload extension library as
    voice.atunload.
"""

try:
    from _voice_atunload import *
except ImportError:
    """ When the _voice_atunload extension library isn't available,
    implement documentation-only versions of the functions.

    This exists only to provide Eclipse-readable documentation for
    Python functions implemented within VoiceCatalyst (and hence unknown
    to Eclipse).

    All functions in this collection, therefore, raise
    NotImplementedError if called.
    """


    def register(func):
        """ Register a function to be called when the application is unloaded.
        """
        raise NotImplementedError

    def unregister(func):
        """ Remove a function from the list of functions to be called when 
        the application is unloaded.
        """
        raise NotImplementedError
