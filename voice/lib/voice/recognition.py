""" recognition.py: shell module to import _voice_recognition extension library as
    voice.recognition.
"""

try:
    from _voice_recognition import *
except ImportError:
    """ When the _voice_recognition extension library isn't available,
    implement documentation-only versions of the functions.

    This exists only to provide Eclipse-readable documentation for
    Python functions implemented within VoiceCatalyst (and hence unknown
    to Eclipse).

    All functions in this collection, therefore, raise
    NotImplementedError if called.
    """
    
    def set_suppress_recognition(suppress):
        """Suppresses or un-suppresses the recognizer
        
        The suppress Boolean flag will set the state of the recognizer.  If
        the flag is True, the recognizer will be suppressed and placed into
        an inactive state.  A False value for the parameter will remove
        the suppress state.
        
        If necessary, a noise sample and template training will occur when the recognizer
        is un-suppressed.
        
        A RuntimeError will be thrown if the recognizer is suppressed on a
        node that only has vocabulary links as the exit links.
        
        """
        raise NotImplementedError
        
    def is_recognition_suppressed():
        """A check to determine if the recognizer is suppressed.  Returns True or False."""
        raise NotImplementedError
        
    def set_training_done_callback(callback):
        """Sets a callback that will be invoked when template training is completed.   
        """
        raise NotImplementedError
          
    def get_number_of_untrained_templates():
        """Returns the number of untrained templates."""
        raise NotImplementedError
