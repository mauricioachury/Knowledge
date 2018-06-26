""" audio.py: shell module to import _voice_audio extension library as
    voice.audio.
"""

try:
    from _voice_audio import *
except ImportError:
    """ When the _voice_audio extension library isn't available,
    implement documentation-only versions of the functions.

    This exists only to provide Eclipse-readable documentation for
    Python functions implemented within VoiceCatalyst (and hence unknown
    to Eclipse).

    All functions in this collection, therefore, raise
    NotImplementedError if called.
    """


    def beep(pitch_in_hertz=500, duration_in_seconds=0.1):
        """Queue a request to play a beep of specified pitch and
        duration. This is queued in the speech queue (treated like a
        non-priority prompt). The call returns immediately and does
        not wait for the beep to be started or completed. Pitch should
        be a number between 50Hz and 5000Hz, and defaults to
        500Hz. Duration should be an number of seconds between 0.1 and
        5.0, and defaults to 0.1. Raises ValueError on out-of-range
        parameters.
        """
        raise NotImplementedError

    def play(file_path):
        """ Queue a request to play the specified audio file. The
        function supports uncompressed 8-bit .WAV, uncompressed 16-bit
        .WAV, or 16-bit .ogg (Ogg Vorbis) data, at 8kHz, 11.025kHz, or
        16kHz sample rates, with one channel (monaural).

        The call returns immediately and does not wait for the audio
        to be started or completed.
        """
        raise NotImplementedError

    def stop_playing():
        """Stops playing audio. If no audio is being played, returns
        without error.
        """
        raise NotImplementedError

    def start_recording(file_path, max_seconds=None):
        """Begin recording audio. If a recording is already underway,
        it is stopped first. Audio is recorded in 16-bit, monaural,
        uncompressed .WAV format, at 11.025 kHz sample rate. Recording
        continues until either stop_recording() is called, or
        max_seconds has expired (if specified).
        """
        raise NotImplementedError

    def stop_recording():
        """Stops recording audio. If no audio is being recorded, returns
        without error.
        """
        raise NotImplementedError

