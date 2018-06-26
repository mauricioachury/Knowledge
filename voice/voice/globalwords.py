"""globalwords: implementation of global vocabulary words."""

import _voice

class GlobalVocabulary(dict):
    """Mapping of global words to behaviors.

    Once set, the list of global words is immutable; only their
    behaviors can be changed.

    >>> words = GlobalVocabulary({'login':GlobalWord(do_login)})
    >>> words['login'] = GlobalWord()    # raises TypeError
    >>> del words['login']               # raises TypeError
    >>> words['login'].enabled = True    # ok
    >>> words['login'].target = other_fn # ok
    >>> words.reset('login')             # ok

    """
    def __init__(self, *args):
        """Do nothing--initialization happens only at object
        creation."""
        pass

    def setdefault(self, k, d):
        raise TypeError("Cannot add words to GlobalVocabulary.")

    def _prohibit_removal(self):
        raise TypeError("Cannot remove words from GlobalVocabulary.")
    __delitem__ = clear = pop = popitem = _prohibit_removal

    def update(self, other):
        if set(other.keys()) - set(self.keys()):
            raise TypeError("Cannot add words to GlobalVocabulary.")

    def __setitem__(self, key, item):
        if key not in self:
            raise TypeError("Cannot add words to GlobalVocabulary.")
        dict.__setitem__(self, key, item)

    def __new__(cls, *args):
        """Create and initialize a new mapping."""
        self = dict.__new__(cls)
        dict.__init__(self, *args)
        return self

    def reset(self):
        """Reset all global words' behaviors to their original settings."""
        for word in self.values():
            word.reset()

class GlobalWord(object):
    """Definition of the behavior of a global word."""
    def __init__(self, word, target, enabled, echo):
        self.__word = word
        self.__target = target
        self.__enabled = enabled
        self.echo = echo
        self.__reset_state = (target, enabled, echo)

    def _set_target(self, target):
        prev, self.__target = self.__target, target
        if (prev is None) != (target is None):
            _voice._flag_global_grammar_for_recompilation()

    def _get_target(self):
        return self.__target

    target = property(_get_target, _set_target)

    def _set_enabled(self, val):
        prev, self.__enabled = self.__enabled, val
        if prev != val:
            _voice._flag_global_grammar_for_recompilation()

    def _get_enabled(self):
        return self.__enabled

    enabled = property(_get_enabled, _set_enabled)

    def _set_word(self, val):
        raise TypeError("Cannot change word attribute on GlobalWord.")

    def _get_word(self):
        return self.__word

    word = property(_get_word, _set_word)

    def reset(self):
        """Reset this global word's behavior to its original settings."""
        self.target, self.enabled, self.echo = self.__reset_state

# words is initialized by VoiceClient at application load time.
words = GlobalVocabulary()

