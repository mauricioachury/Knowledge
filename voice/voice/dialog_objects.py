""" Objects implementing dialog flows.
"""

import _voice
import voice

class Dialog(object):
    """An executable set of application nodes and their links.  The auto_clean_up
    parameter indicates if the memory associated with the Dialog object should
    automatically be deallocated at the conclusion of the run() method.  If the
    parameter is False, then the developer is responsible for calling the clean_up()
    method on the Dialog to deallocate this memory.  If the parameter is True, then
    the memory will automatically be deleted, and any further calls to the run()
    method will result in a RuntimeError exception.
    """
    def __init__(self, name='', auto_clean_up=False):
        self.name = name
        self.nodes = {}
        self.links = {}
        self.result = None
        self._current_node = None
        self._recog_handle = 0
        self._dialog_is_global = False
        self._dialog_is_command = False
        self._auto_clean_up = auto_clean_up
        self._dialog_is_clean = False
        _voice.initialize_dialog(self)

    def run(self):
        if self._dialog_is_clean:
            raise RuntimeError("Cannot run dialog since it has already been cleaned up")
        _voice.launch_dialog(self)
        return self.result

    def clean_up(self):
        _voice.clean_up_dialog(self)

    @property
    def current_node(self):
        return self._current_node


class Node(object):
    """A single state in an application dialog.

    A node may be given a response_expression to be used as a hint by
    the recognition system. A response_expression may be a single
    string or a list of strings.

    e.g.
    node.response_expression = 'foo'
    node.response_expression = ['foo', 'bar']
    """
    def __init__(self,
                 name,
                 prompt='',
                 help_prompt='',
                 prompt_is_priority=False,
                 on_entry_method='',
                 on_entry_method_args=set([])):
        self.name = name
        self.prompt = prompt
        self.help_prompt = help_prompt
        self.response_expression = ''
        self.prompt_is_priority = prompt_is_priority
        self.on_entry_method = on_entry_method
        self.on_entry_method_args = on_entry_method_args

        self._recog_handle = 0
        self.last_entry_time = None
        self.last_recog = None
        self.is_allow_speak_ahead_node = True

        self.out_links = []
        self.in_links = []

    @property
    def has_vocab(self):
        for item in self.out_links:
            if item._is_vocab_link:
                return True

        return False

    @property
    def seconds_since_entry(self):
        """ Return the number of seconds since the application entered this Node.
            If the application has not yet entered this Node, return a negative
            value"""
        if (self.last_entry_time == None):
            return -1
        else:
            return voice.current_time() - self.last_entry_time

class Link(object):
    """A transition between dialog nodes."""
    def __init__(self,
                 name,
                 source_node,
                 dest_node,
                 existing_vocab = [],
                 conditional_method = '',
                 conditional_method_args=set([]),
                 link_is_echo = False):
        self.name = name
        self.source_node = source_node
        self.dest_node = dest_node
        self._vocab = Vocabulary(self, existing_vocab)
        self._is_vocab_link = len(existing_vocab) > 0

        self._conditional_method = conditional_method
        self.conditional_method_args = conditional_method_args
        self._conditional_code = None

        self.link_is_echo = link_is_echo
        self.is_allow_speak_ahead_link = True

        source_node.out_links.append(self)
        dest_node.in_links.append(self)

    def _get_vocab(self):
        return self._vocab

    def _set_vocab(self, new_value):
        if not self._is_vocab_link:
            raise ValueError("Non-Vocabulary links may not contain vocabulary")
        elif not new_value:
            raise ValueError("Vocabulary links must always contain vocabulary")

        new_vocab = Vocabulary(self, new_value)

        self._vocab._verify_modification(self._vocab, new_vocab)

        if self._vocab != new_vocab:
            self._vocab = new_vocab
            _voice._flag_grammar_for_recompilation()

    vocab = property(_get_vocab, _set_vocab)

    def _get_conditional_method(self):
        return self._conditional_method

    def _set_conditional_method(self, new_value):
        if not self._conditional_method:
            raise ValueError("Cannot set conditional method on nonconditional link")
        elif not new_value:
            raise ValueError("Cannot clear conditional method on conditional link")

        self._conditional_method = new_value
        self._conditional_code = None

    conditional_method = property(_get_conditional_method, _set_conditional_method)

class Vocabulary(set):
    """Vocabulary set.  Modifications to the contents are validated against
    dialog rules, and mark the recognition grammar as "dirty" (needing
    recompilation).
    """

    def __init__(self, parent_link, existing_vocab = []):
        set.__init__(self, existing_vocab)
        self._parent_link = parent_link

        self.supports_dynamic_templates = False

        # This property must be present and set to exactly "true", otherwise, it defaults to false.
        dynamic_template_env_value = voice.getenv('Audio.DynamicTemplateCreationSupported')
        if ((dynamic_template_env_value is not None) and (dynamic_template_env_value.lower() == 'true')):
            self.supports_dynamic_templates = True

    def _generic_operation_structure(self, other, operation):
        # Stage operation
        original_set = self.copy()
        new_set = self.copy()
        operation(new_set, other)
        # Verify operation
        self._verify_modification(original_set, new_set)
        # Execute operation
        operation(self, other)
        if self != original_set:
            _voice._flag_grammar_for_recompilation()

    def _generic_operation_structure_noargs(self, operation):
        # Stage operation
        original_set = self.copy()
        new_set = self.copy()
        operation(new_set)
        # Verify operation
        self._verify_modification(original_set, new_set)
        # Execute operation
        operation(self)
        if self != original_set:
            _voice._flag_grammar_for_recompilation()


    def __ior__(self, other):
        self._generic_operation_structure(other, set.update)
        return self

    def __iand__(self, other):
        self._generic_operation_structure(other, set.intersection_update)
        return self

    def __isub__(self, other):
        self._generic_operation_structure(other, set.difference_update)
        return self

    def __ixor__(self, other):
        self._generic_operation_structure(other, set.symmetric_difference_update)
        return self

    def add(self, elem):
        self._generic_operation_structure(elem, set.add)

    def remove(self, elem):
        self._generic_operation_structure(elem, set.remove)

    def discard(self, elem):
        self._generic_operation_structure(elem, set.discard)

    def pop(self):
        self._generic_operation_structure_noargs(set.pop)

    def clear(self):
        self._generic_operation_structure_noargs(set.clear)

    def _verify_modification(self, original, new_vocab):
        if original != new_vocab:
            self._verify_vocab(new_vocab)
            self._verify_valid_modification(original, new_vocab)
            self._verify_unique_vocab_per_node(new_vocab)

    def _verify_vocab(self, new_vocab):
        if not new_vocab <= voice.get_all_vocabulary_from_vad():
            # If we support dynamic templates, we will generate one on the fly.
            if not self.supports_dynamic_templates:
                voice.log_message("System doesn't support dynamic templates - raising error")
                raise ValueError("Only vocabulary that has already been trained is valid")

    def _verify_valid_modification(self, original, new_vocab):
        if len(original) == 0 and not len(new_vocab) == 0:
            raise ValueError("Non-Vocabulary links may not contain vocabulary")
        elif len(original) > 0 and not len(new_vocab) > 0:
            raise ValueError("Vocabulary links must always contain vocabulary")

    def _verify_unique_vocab_per_node(self, new_vocab):
        source_node = self._parent_link.source_node

        all_vocab = set([])
        for link in source_node.out_links:
            if link is self._parent_link:
                if len(new_vocab & all_vocab) != 0:
                    raise ValueError("Vocabulary from a Node must be unique")
                all_vocab |= new_vocab
            else:
                if len(link.vocab & all_vocab) != 0:
                    raise ValueError("Vocabulary from a Node must be unique")
                all_vocab |= link.vocab

