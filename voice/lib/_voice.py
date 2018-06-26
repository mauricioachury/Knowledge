""" _voice_doc: documentation-only implementations of internal
    functions.

    None of the functions in this module should ever be called; they
    exist only to provide Eclipse-readable documentation for Python
    functions implemented within VoiceClient (and hence unknown to
    Eclipse).

    All functions in this module therefore raise NotImplementedError
    if called.
"""

def current_dialog():
    """Return the currently-executing dialog instance, or None if no
    dialog is executing.
    """
    raise NotImplementedError

def log_message(message_string):
    """Enter a message into the VoiceClient runtime debug log at the
    INFO level.
    """
    raise NotImplementedError

def pause_processing():
    """Cause voice processing system to enter a paused state."""
    raise NotImplementedError

def start_noise_sample():
    """Cause voice processing system to initiate a noise sample.  
    A RuntimeError is thrown if the recognizer is suppressed.
    """
    raise NotImplementedError

def increase_volume():
    """Increase the output volume of the TTS by 1 step if possible."""
    raise NotImplementedError

def decrease_volume():
    """Decrease the output volume of the TTS by 1 step if possible."""
    raise NotImplementedError

def get_tts_properties():
    """ Retrieve a dictionary of the current TTS settings. """
    raise NotImplementedError

def set_tts_properties(**kwargs):
    """ Override operator TTS settings. """
    raise NotImplementedError

def reset_tts_properties():
    """ Cancel override settings to restore operator TTS settings. """
    raise NotImplementedError

def get_voice_application_property(name):
    """Retrieve a single property associated with the currently
    loaded voice application."""
    raise NotImplementedError

def get_all_voice_application_properties():
    """Return a dict containing all properties associated with the
    currently loaded voice application.
    """
    raise NotImplementedError

def get_all_vocabulary_from_vad():
    """Retrieve all vocabulary associated with the currently loaded
    voice application.
    """
    raise NotImplementedError

def get_last_prompt():
    """Retrieve last prompt spoken string value.
    """
    raise NotImplementedError

def set_last_prompt(prompt_string):
    """Set last prompt spoken string value.
    """
    raise NotImplementedError

# get_config_value, set_config_value, and query_config_value_info
# are not yet implemented in Ledbird; in particular, 
# query_config_value_info may change during implementation.
# So we should avoid documenting them for now.

# def get_config_value(name):
#     """Retrieve a configuration value by its name."""
#     raise NotImplementedError

# def set_config_value(name, value):
#     """Set a configuration value by its name."""
#     raise NotImplementedError

# def query_config_value_info():
#     """Retrieve information about a configuration value by its
#     name.

#     Returns a tuple of information: (description, type, validation, defaultValue, agentValue
#     """
#     raise NotImplementedError

def get_persistent_store_path():
    """Return the path where persistent data should be saved."""
    raise NotImplementedError

def get_vad_path():
    """Return the path to the currently running voice application
    distributable file.
    """
    raise NotImplementedError

def trigger_scanner(timeout_seconds):
    """Cause the scanner to fire and look for barcodes/tags.
    
    timeout_seconds: the duration in seconds for which the scanner should actively scan
    
    It is assumed that the scanner callback has been set using scan_callback
    Failure to do so results in the call to trigger_scanner being ignored
    """
    raise NotImplementedError

def set_event_callback(generic_callback, eventType):
    """Register a callback function.
    generic_callback can be any callable object.
    event_type is an enumerated data which tells the type of event for
    which the callback has to be registered. The enum is defined in
    RexContext.h file.
    """
    raise NotImplementedError
    
def get_task_configuration():
    """Get config.xml present in task package.
    This function returns the congfiguration xml present in task
    package to VoiceApp developer in a DOM tree structure
    """
    raise NotImplementedError

def set_scan_callback(scan_callback):
    """Register a scan callback function.
    
    scan_callback can be any callable object. It must accept a single
    positional argument that contains the result of each successful
    scan as a string. If scan_callback is None, any existing callback
    is cleared.
    
    If scan_callback is not None, and the device doesn't support a
    scanner or any required setup with the scanner is unable to occur,
    an exception will be thrown when set_scan_callback is called.
    
    If the callback raises an exception, the exception will be caught
    and logged, but will not cause any other failure behavior (no
    automatic shutdown, no spoken message, etc).
    
    If set_scan_callback was called before with a valid scan callback, 
    and it is called again with a different callback, the most
    recent callback will replace any older registered callback.
    
    Note: This callback should consume minimal time before
    returning (such as a simple store of the result, and triggering of
    another thread to consume the data), as this callback may be called
    in the context of a device-specific (possibly even driver) thread.
    """
    raise NotImplementedError

def  set_buttons_callback(buttons_callback):
    """To override the default button functionality set a callback function. 
    The function must be a callable, Pass None to restore the default 
    button functionality.
    
    The callback function must accept a single positional argument.  This
    argument is an integer ID of the button pressed.  The callback can
    consume the button event by returning True.  If the button event is consumed,
    the device's default button action does not occur.  Returning False from
    the callback will allow the device's default button action to occur.
    
    The buttons have behaviors when held down that should be noted.  Holding
    down the Play/Pause button will power the device off.  Holding the
    Plus and Minus buttons will result in multiple button events.  The multiple
    events are designed to allow for quick scrolling through list items.  Holding
    the Operator button will result in single button event.    
    """
    raise NotImplementedError
    
def  getenv(key, default_value):
    """Get the environment value associated with key.  If it does not exist
    in the voice environment, then return default_value.
    
    There are many environment keys.  For a full list, use voice.getenvkeys.
    
    Some keys of interest:
    Device.Id - The device ID or serial number, depending on the platform.
    Operator.Name - The name of the currently loaded operator
    Operator.Id - The id of the currently loaded operator
    """
    raise NotImplementedError
    
def  getenvkeys():
    """Get a list of all environment keys that voice.getenv will have 
    meaningful information about.
    
    Some keys of interest:
    Device.Id - The device ID or serial number, depending on the platform.
    Operator.Name - The name of the currently loaded operator
    Operator.Id - The id of the currently loaded operator
    """
    raise NotImplementedError
    
def  set_print_complete_callback(print_complete_callback):
    """Register a print complete callback function.
    
    set_print_complete_callback can be any callable object. It must
    accept a single positional argument that contains the result of the
    print command as a string ("failure" or "success"). If
    set_print_complete_callback is None, any existing callback is cleared.
    
    """
    raise NotImplementedError

def print_data(data_buffer, code_page=65001):
    """Queue a request to print the characters in the data_buffer.
    This is queued in the print service. The call returns immediately
    and does not wait for the print to be started or completed.  The
    print_complete_callback function will be called when the print
    command has been processed.  The default of the code_page is 65001,
    the winnls.h value for CP_UTF8.
    """
    raise NotImplementedError

def  set_locale_changed_callback(locale_changed_callback):
    """Register a locale changed callback function.
    
    set_locale_changed_callback can be any callable object. It must
    accept a single positional argument that contains the new locale 
    as a string (e.g. "en_US"). If set_locale_changed_callback is 
    None, any existing callback is cleared.
    
    """
    raise NotImplementedError


class CannotRunDialogError:
    """Raised when a dialog is not allowed to be run, such as from within
    a conditional link method call.
    """
    pass
class DialogRunningError:
    """Raised when a dialog is attempted to be run but is already running
    """
    pass
class DialogUndefinedError:
    """Raised when a dialog is attempted to be run that does not exist in
    the application.
    """
    pass
class ConfigNotFound:
    """Raised when a config item name is not found.
    """
    pass
class ConfigAccessDenied:
    """Raised when access (read or write) to a config item is not allowed.
    """
    pass
class ConfigInvalidValue:
    """Raised when a config item is attempted to be written with an invalid
    value.
    """
    pass
