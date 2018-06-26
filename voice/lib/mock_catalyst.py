#
# Copyright (c) 2010-2014 Vocollect, Inc.
# Pittsburgh, PA 15235
# All rights reserved.
#
# This source code contains confidential information that is owned by
# Vocollect, Inc. and may not be copied, disclosed or otherwise used without
# the express written consent of Vocollect, Inc.
#

#import xml.etree.ElementTree
from xml.etree.ElementTree import ElementTree, SubElement, Element, tostring
import time
import os
import sys
import _thread
import io
import atexit

#only import so they can be overridden
import voice #@UnusedImport
import voice.audio #@UnusedImport
import voice.atunload #@UnusedImport
import voice.recognition #@UnusedImport
import voice.globalwords
import zipfile

mock_function_prompts = ['beep', 'Stop playing called', 'Stop recording called']

class PromptList(list):
    
    def pop(self, i = None, ret_type = str):
        #Do super pop based on i
        if i is None:
            result = super().pop()
        else:
            result = super().pop(i)
        
        #determine what to return based on what user
        #asked for. Older versions of core library (1.0 and 1.1)
        #don't ask for anything, therefore default just return str (or prompt)
        #if list is asked for then return full element that was popped
        if ret_type == str and type(result) == list:
            return result[0]
        else:
            return result
        
#=========================================================================
#used to load and configure mock catalyst first time imported
__loaded = False
__running_vad = False
__vad_file = None

__proj_refs = {}
__main_proj = ''

#=========================================================================
#main test framework, set from TestAndDebug.py
use_stdin_stdout = True #set to False for testing purposes 
response_queue = [] #append words to bypass stdIn
response_map = {} #Add desired vocab as key, and value as actual vocab. used for 
                  #translations/phonetics 
#=========================================================================
# properties of modules used mainly during tests to see what happened during a run.
responses = [] #list of responses recognized during run
prompts = PromptList() #list of prompts spoken during run
responses_to_prompts = [] #list of pairs of responses to prompts.
log_messages = [] #list of log messages posted using voice.log_message()
_last_prompt = '' #The last thing spoken to the user
_task_configuration = '' #mock contents of config.xml of a vat file
_print_log_message = False      # set to true for mock_catalyst to use print() 
                                # on all log_messages as they happen
                                
#=========================================================================
#Dialog variables, for dialog templates, list of currently running dialogs
dialog_templates = {}
running_dialogs = []

#modules for running commands
global_modules = {}

#=========================================================================
#Vocabulary variables for all vocabulary as well as global vocabulary
all_vocab = []


#=========================================================================
#global to hold flag indicating if recognition is suppressed or not
#       There is no functionality behind this variable
recognition_suppressed = False

#=========================================================================
#global to hold number of untrained templates
#       There is no functionality behind this variable
untrained_templates = 0

#=========================================================================
#Application properties from the voiceconfig.xml
application_properties = None
environment_properties = {}

#=========================================================================
#default tts property values
user_tts_properties = {'volume' : 5, 'speed' : 5, 'pitch' : 5, 'speaker' : 0}
default_tts_properties = {'volume': 5, 'speed' : 5, 'pitch' : 5, 'speaker' : 0}

#=========================================================================
# constants for button identification
BUTTON_MAPPINGS = { "0" : 0, "plus" : 0, "1" : 1, "minus" : 1, "2" : 2, "play" : 2, "3" : 3, "operator" : 3}


# map of event callbacks - if catalyst added event callbacks, this map needs to be updated.
# NOTE:  If catalyst adds events, update set_event_callback method 
EVENT_CB_MAPPING = {"1": None, "2": None, "3": None, "4": None,
                    "5": None, "6": None, "7": None, "8": None}


# Return the number of the button pressed, if it was a button press.
# Return None if it was not a button press.
def button_pressed(response):
    if response.startswith('~'):
        try:
            return BUTTON_MAPPINGS[response[1:].strip()]
        except KeyError:
            return None
    else:
        return None

    
class MockGlobalWord(object):
    """Definition of the behavior of a global word."""
    def __init__(self, word, target, enabled, echo):
        self.word = word
        self.target = target
        self.enabled = enabled
        self.echo = echo
        self.__reset_state = (target, enabled, echo)

    def reset(self):
        """Reset this global word's behavior to its original settings."""
        self.target, self.enabled, self.echo = self.__reset_state

#=========================================================================
#Helper methods and classes
def post_prompt(prompt, priority_prompt = False):
    global prompts
    """ typically called from code to post a prompt that would have been spoken """
    prompts.append([prompt, priority_prompt])
    set_last_prompt(prompt)
    
    if use_stdin_stdout:
        sys.stdout.write(prompt)
        if priority_prompt:
            sys.stdout.write('<pp>')
        
        if prompt in mock_function_prompts:
            sys.stdout.write('\n')
            
        sys.stdout.flush()

def post_dialog_responses(*responses):
    global response_queue
    for response in responses:
        response_queue.append(response)

class EndOfApplication(Exception):
    ''' Exception for end of application '''
    pass


#=================================================================
# Process for getting input from stdin. It is always running on a 
# separate thread to allow for future implementation of things like scanning
# However this has a side effect of the application possibly not shutting down 
# completely if this thread is waiting for input. Hitting enter should 
# allow the thread to end.
#=================================================================
input_data = []
app_running = True
waiting_input = False
prompt_displayed = False

def get_input():
    global input_data, waiting_input, app_running
    global use_stdin_stdout, response_queue, responses, responses_to_prompts
    global EVENT_CB_MAPPING
    
    try:
        while app_running:
            response = None
            if waiting_input and len(input_data) == 0:
                try:
                    if len(response_queue) > 0:
                        response = response_queue.pop(0)
                        if use_stdin_stdout:
                            sys.stdout.write('<' + response + '>\n')
                            sys.stdout.flush()
                    elif use_stdin_stdout:
                        response = input()
                        response = response.replace("\r","").replace("\n","")
                except:
                    response = '-'
    
                waiting_input = False
                if response in response_map.keys():
                    response = response_map[response]
                    
                #set some defaults
                if response == '':
                    response = 'ready'
                elif response is None:
                    response = '^'
    
                if response.startswith("#") and EVENT_CB_MAPPING[str(voice.EVT_SCAN_CB)] is not None:
                    EVENT_CB_MAPPING[str(voice.EVT_SCAN_CB)](response[1:])
                elif button_pressed(response) is not None and EVENT_CB_MAPPING[str(voice.EVT_BUTTON_CB)] is not None:
                    EVENT_CB_MAPPING[str(voice.EVT_BUTTON_CB)](button_pressed(response))
                else:
                    input_data.append(str(response) + '\n')
                
                responses.append(response)
                try:
                    #this only here to compensate for synchronization. 
                    responses_to_prompts.append([response, current_dialog()._last_prompt])
                except:
                    pass
            
                    
            else:
                if use_stdin_stdout:
                    while not waiting_input:
                        time.sleep(0.03)
    except Exception as err:
        print(err)
        
_thread.start_new_thread(get_input, ())


#=================================================================
# VID Classes, Nodes, Links, and Dialogs
#=================================================================
class Node(voice.dialog_objects.Node):
    ''' Node class for emulating nodes '''
    def __init__(self,
                 name,
                 prompt='',
                 help_prompt='',
                 prompt_is_priority=False,
                 on_entry_method='',
                 on_entry_method_args=set([])):
        
        super(Node, self).__init__(name, prompt, help_prompt, prompt_is_priority, on_entry_method, on_entry_method_args)
        
        # Reassignment of base-defined props
        self.last_entry_time = 0
        
        # MockCatalyst props used in implementation
        self.dialog = current_dialog() #default to currently running dialog, will be none if one doesn't exist
        self._input_thread = None
        self._seconds_since_entry = 0
        self._vocab = []
    
    @property
    def seconds_since_entry(self):
        """ Return the number of seconds since the application entered this Node.
            If the application has not yet entered this Node, return a negative
            value"""
        return self._seconds_since_entry
    
    def execute(self):
        ''' Main method to execute the node. This method is caled when 
        the node is entered
        '''
        global waiting_input, prompt_displayed
        
        waiting_input = False
        
        self._seconds_since_entry = 0
        last_time = time.time()
        
        #Process on Entry method
        if (self.on_entry_method is not None
            and self.on_entry_method != ''):
            execute_method(self.on_entry_method)

        #get All Vocabulary out of node
        #Done here in case on entry method changed vocabulary
        self._vocab = []
        for link in self.out_links:
            if link.is_vocabulary():
                self._vocab.extend(link.vocab)

        #speak/print prompt
        if self.prompt != '' and self.prompt is not None:
            self.dialog._last_prompt = self.prompt
            if self.dialog._prompt_only:
                if use_stdin_stdout:
                    print('')
            else:
                self.dialog._prompt_only = True
            post_prompt(self.prompt, self.prompt_is_priority)
            voice.last_prompt_spoken = self.prompt
            voice.last_prompt_is_priority = self.prompt_is_priority
            prompt_displayed = True

        if prompt_displayed and self.has_vocab:
            if use_stdin_stdout:
                sys.stdout.write(' : ')
                sys.stdout.flush()
            prompt_displayed = False

        #If there are out links then continually process 
        #until one returns true 
        if len(self.out_links) > 0:
            while not self.process_links():
                time.sleep(0.01)
                self._seconds_since_entry = self._seconds_since_entry + (time.time() - last_time)
                last_time = time.time()

        
    def process_links(self):
        ''' process_links - process all out links for the node, 
            1. conditional links first
            2. default links seconds
            3. vocabulary links last
        '''
        global responses_to_prompts
        
        if self._process_conditional_links():
            #Check if timeout occurred, if so add ! to last entry
            #This is current done by assuming that if the conditional link
            # failed the first time, then passed later (self.seconds_since_entry > 0)
            # then it must be because of a timeout. This will need reviewed when
            # test framework is updated with scanning or other inputs.
            if self.seconds_since_entry > 0:
                if len(responses_to_prompts) > 0:
                    last = responses_to_prompts.pop()
                    if not last[0].endswith('!') and not last[0].startswith('#'):
                        last[0] += '!'
                    responses_to_prompts.append(last)
            
            return True
        elif self._process_default_link():
            return True
        elif self._process_vocab_links():
            self.dialog._prompt_only = False
            return True
        else:
            return False
        
    def _process_default_link(self):
        ''' _process_default_link - checks out links for a default link 
        if one is found, then set the main dialogs next node to it's 
        destination and return true
        '''
        for link in self.out_links:
            if link.is_default():
                self.dialog._next_node = self.dialog.nodes[link.dest_node]
                return True
    
    def _process_conditional_links(self):
        ''' _process_conditional_links - check all conditional links 
        in the defined execution order and execute their conditional method
        if method returns true, then set the main dialogs next node to it's 
        destination and return true
        '''
        #execution order, assumes links are number from 1..n with no gaps
        exec_order = 1
        while exec_order > 0:
            #get link with execution order
            link = None
            for l in self.out_links:
                if l.execution_order == exec_order:
                    link = l

            #if link not found, then set exec_order to 0 to end loop
            if link is None:
                exec_order = 0
            else:
                #if link found and method evaluates to true, then set the 
                #main dialogs next node to it's destination and return true
                #Else increment exec_order for next conditional link
                if execute_method(link.conditional_method):
                    self.dialog._next_node = self.dialog.nodes[link.dest_node]
                    return True
                else:
                    exec_order += 1
                
        return False        
    
    def _process_vocab_links(self):
        ''' _process_vocab_links - process vocabulary links by checking the
        command line input thread for any input and trying to find best match based
        on that input. Attempts to match vocabulary on node as well as global vocabulary 
        '''
        global input_data, waiting_input
        vocab_match = None
        
        #check data from command line input thread and check for best
        #match (if any) and if found,then, set the main dialogs next 
        #node to it's destination and return true 
        vlen = 0 #Use to find longest matching vocab
        if len(self._vocab) > 0:
            while vocab_match == None and len(input_data) > 0:
                resp = input_data.pop(0)
                
                #check special cases
                if resp.startswith('-'):
                    raise EndOfApplication()
                elif resp.startswith('^'):
                    error_message = 'No Response - dialog: \'' + self.dialog.name \
                           + '\' node: \'' + self.name \
                           + '\' previous prompts: ' + str(responses_to_prompts)
                    raise Exception(error_message)
                elif resp.startswith('!'):
                    waiting_input = False
                    self._seconds_since_entry = 1000000000
                    return
                
                if resp.startswith('talkman help'):
                    if self.help_prompt is None or self.help_prompt == '':
                        post_prompt('[standard help]')
                    else:
                        post_prompt(self.help_prompt)

                    if use_stdin_stdout:
                        print('')
                    post_prompt(self.dialog._last_prompt)
                        
                    return False
                
                elif resp.startswith('talkman sleep'):
                    if EVENT_CB_MAPPING[str(voice.EVT_TERMINAL_SLEEP_CB)]:
                        EVENT_CB_MAPPING[str(voice.EVT_TERMINAL_SLEEP_CB)]()
                        pause_processing()
                            
                elif resp.startswith('talkman wakeup'):
                    if EVENT_CB_MAPPING[str(voice.EVT_TERMINAL_WAKEUP_CB)]:
                        EVENT_CB_MAPPING[str(voice.EVT_TERMINAL_WAKEUP_CB)]()
                    post_prompt(get_last_prompt())
                    
                #Get best matching regular vocab
                for v in self._vocab:
                    if len(v) > vlen and resp.startswith(v):
                        vocab_match = v
                        vlen = len(v)

                #Get best matching global vocab
                for word in list(voice.globalwords.words.keys()):
                    if voice.globalwords.words[word].enabled:
                        if len(word) > vlen and resp.startswith(word):
                            vocab_match = word
                            vlen = len(word)

                # check if input not fully used, if not then put back in 
                # response list. This usually occurs for digit entry
                if vocab_match is not None:
                    resp = resp[vlen:]
                    if resp[0] not in ['\n', '\r']:
                        input_data.insert(0, resp)
                else:
                    if resp.startswith('say again'):
                        post_prompt(get_last_prompt())

        # if a match was found
        if vocab_match is not None and not is_recognition_suppressed():
            #Check for link to take
            for link in self.out_links:
                if vocab_match in link.vocab:
                    self.dialog._next_node = self.dialog.nodes[link.dest_node]
                    self.last_recog = vocab_match
                    waiting_input = False #No longer waiting for input
                    return True
            
            #check if global matched, and execute global function    
            if vocab_match in voice.globalwords.words:
                if voice.globalwords.words[vocab_match].enabled:
                    execute_method(voice.globalwords.words[vocab_match].target)
                    #After executing global, repeat current dialogs last prompt. 
                    if self.prompt is None or self.prompt == '':
                        post_prompt(self.dialog._last_prompt)
                    else:
                        post_prompt(self.prompt)
                    return False
        
        #If we got here, then there was no match. So make sure 
        #waiting for input is still on. Also this is the first place
        #it is turned on so it is not on if conditional link was true to prevent
        # hanging of application thread 
        if len(self._vocab) > 0 and len(input_data) == 0 and not waiting_input:
            waiting_input = True
         
        return False
    
class Link(voice.dialog_objects.Link):
    ''' Link class - main class for emulating links
    '''
    def __init__(self,
                 name,
                 source_node,
                 dest_node,
                 existing_vocab = [],
                 conditional_method = '',
                 conditional_method_args=set([]),
                 link_is_echo = False):
        
        super(Link, self).__init__(name, source_node, dest_node, existing_vocab, conditional_method, conditional_method_args, link_is_echo)

        # These are names in MockCatalyst instead of actual Node objects.
        self.source_node = source_node.name
        self.dest_node = dest_node.name

        # Override to use words instead of Vocabulary objects     
        self.vocab = set(existing_vocab)

        # MockCatalyst property
        self.execution_order = 0


    def is_conditional(self):
        ''' is_conditional - returns true if link is a conditional link 
        (has a conditional method) 
        '''
        value = (self.conditional_method is not None
                and self.conditional_method != '')
        return value
    
    def is_vocabulary(self):
        ''' is_vocabulary - returns true if link is a vocabulary link
        (length of vocab set > 0)
        '''
        value = len(self.vocab) > 0 
        return value
    
    def is_default(self):
        ''' is default - returns true if link is a default link 
        (not a vocabulary and not a conditional link)
        '''
        return not self.is_vocabulary() and not self.is_conditional()

    # Override setter/getter pair for vocab. MockCatalyst doesn't
    # use Vocabulary objects, just words.
    def _set_vocab(self, new_value):
        self._vocab = new_value

    def _get_vocab(self):
        return self._vocab

    vocab = property(_get_vocab, _set_vocab)

class Dialog(voice.dialog_objects.Dialog):
    ''' Dialog Class - main class for emulating a dialog.
    '''
    def __init__(self, dialog_name = None):
        
        super(Dialog, self).__init__(dialog_name)
        
        
        #Properties for determining what node to execute
        self._start_node = None
        self._next_node = None

        #Helper properties for displaying information cleanly in console
        self._last_prompt = ''
        self._prompt_only = False
        
        #If no name is provided then assumed to be a template. 
        #if name is provided then assumed to be new instance so 
        #copy template with same name
        if dialog_name is not None:
            temp = dialog_templates[dialog_name]
            self.name = temp.name
            self._start_node = temp._start_node
            
            #=================================================================                
            for node in temp.nodes.values():
                n = Node(node.name, 
                         node.prompt, 
                         node.help_prompt, 
                         node.prompt_is_priority, 
                         node.on_entry_method)
                n.dialog = self
                n.out_links = []
                n.in_links = []
                self.nodes[n.name] = n
                
            for link in temp.links.values():
                v = []
                for vocab in link.vocab:
                    v.append(vocab)
                    
                l = Link(link.name, 
                         self.nodes[link.source_node], 
                         self.nodes[link.dest_node], 
                         v, link.conditional_method, None, link.link_is_echo)
                l.link_is_echo = link.link_is_echo
                l.execution_order = link.execution_order
                
                l.dialog = self
                self.links[l.name] = l

    def run(self):
        ''' run - simulates running of a dialog '''
        global running_dialogs, input_data

        #make sure any created nodes and links have dialog property set
        for node in self.nodes.values():
            node.dialog = self
        for link in self.links.values():
            link.dialog = self
        
        #clear console input, assumes no speak ahead across dialogs
        del input_data[:]
        
        #save dialog to stack of running dialogs
        running_dialogs.append(self)

        
        try:
            #set current node to start node
            self._current_node = self.nodes[self._start_node]
            
            #start executing nodes by running current node, when it completes
            #set current node to next node and next node to none. Continue until
            #current node ends up as None. It is a nodes responsibility to set
            # the dialogs next_node property if a out link was true.
            while self._current_node is not None:
                self._current_node.execute()
                self._current_node = self._next_node
                self._next_node = None

            #check if prompt only dialog (no vocab after prompting)
            if self._prompt_only:
                if use_stdin_stdout:
                    print('')
        finally:
            #always remove from running dialog stack even if errors occured
            running_dialogs.pop()

def initialize_dialog(dialog):
    pass

def clean_up_dialog(dialog):
    pass

#=================================================================
# Additional overridden voice elements
#=================================================================
def beep(pitchInHertz=500, durationInTenthsOfSeconds=0.3):
    post_prompt(mock_function_prompts[0])

def play(file_path):
    post_prompt('Play Called on: ' + str(file_path))
    
def stop_playing():
    post_prompt(mock_function_prompts[1])

def start_recording(file_path, max_seconds=None):
    post_prompt('Play Called on: ' + str(file_path) + ' Max Seconds: ' + str(max_seconds))

def stop_recording():
    post_prompt(mock_function_prompts[2])

def get_number_of_untrained_templates():
    global untrained_templates
    return untrained_templates

def set_suppress_recognition(flag):
    global recognition_suppressed, untrained_templates
    
    old_flag = recognition_suppressed    
    recognition_suppressed = flag
    
    # Output that we have suppressed recognition if the flag state
    # changed from False to True
    if not old_flag and flag:
        
        if use_stdin_stdout:
            sys.stdout.write('<Recognition Suppressed>\n')
            
            sys.stdout.flush()
    elif old_flag and not flag:
        
        if use_stdin_stdout:
            sys.stdout.write('<Recognition Enabled>\n')
            sys.stdout.flush()
        
        # Switching from suppressed to unsupressed triggers noise
        # sample and training
        start_noise_sample()
        if untrained_templates > 0:
            if untrained_templates == 1:
                msg = '<Training 1 template>\n'
            else:
                msg = '<Training %s templates>\n' % untrained_templates
            untrained_templates = 0
        else:
            msg = '<All templates trained>\n'
            
        if use_stdin_stdout:
            sys.stdout.write(msg)
            sys.stdout.flush()
            
        # Call template training callback if registered.
        if EVENT_CB_MAPPING[str(voice.EVT_TRAINING_DONE_CB)]:
            EVENT_CB_MAPPING[str(voice.EVT_TRAINING_DONE_CB)]()
                
        
            
        
    
def is_recognition_suppressed():
    global recognition_suppressed
    return recognition_suppressed

def set_scan_callback(method):
    global EVENT_CB_MAPPING
    EVENT_CB_MAPPING[str(voice.EVT_SCAN_CB)] = method

def set_training_done_callback(method):
    global EVENT_CB_MAPPING
    EVENT_CB_MAPPING[str(voice.EVT_TRAINING_DONE_CB)] = method
    
def log_message(msg):
    global log_messages
    global _print_log_message
    
    log_messages.append(msg)
    
    #check to see if they want log messages printed to console
    if _print_log_message:
        print(msg + '\n')

    sys.stdout.flush()
    sys.stderr.flush()

def get_all_vocabulary_from_vad():
    ''' returns all vocab found in either VID files and voiceconfig.xml
    all loaded when this module is imported
    '''
    global all_vocab
    return all_vocab

def current_dialog():
    ''' returns last dialog in list of running dialogs
    '''
    global running_dialogs
    if len(running_dialogs) > 0:
        return running_dialogs[len(running_dialogs) - 1]
    
    return None

def _istextfile(filename):
    fin = open(filename, 'rb')
    try:
        try:
            chunk = fin.read().decode("utf-8")
        except:
            return 'rb'
            
        if '\0' in chunk: # found null byte
            return 'rb'
    finally:
        fin.close()

    return 'r'

#Globals for simulating files and manifest
#set manifest to a string value for the contents of a simulated manifest file
manifest_contents = None
#Add file to dict file name is the key, and value should be a string containing
#contents of file
resource_files = {}

def open_vad_resource(name, mode = 'r', encoding='utf-8'):
    ''' Searches project and referenced projects resource folders for specifed
    resource. 
    '''
    
    file = None
    if __running_vad:
        file = _open_vad_file(os.path.join('resources/', name), mode)
    else:
        paths = []
        
        #check if opening the manifest.mf file
        if name.lower() == 'manifest.mf':
            if manifest_contents is None:
                tmp_file = _build_manifest_file()
                tmp_file.mode = mode
                return tmp_file
            else:
                tmp_file = io.StringIO(manifest_contents)
                tmp_file.mode = mode
                return tmp_file
    
        #check simulated files
        if name in resource_files:
            tmp_file = io.StringIO(resource_files[name])
            tmp_file.mode = mode
            return tmp_file
         
        #get a list of project directories based on python path
        for path in sys.path:
            if path.endswith('\\src'):
                paths.append(path[:len(path)-3])
        
        #search each project found until specified file is found
        for path in paths:
            try:
                #get mode to open file (text or binary)
                temp_mode = mode
                if mode == 'r':
                    temp_mode = _istextfile(path + 'resources/' + name)
                    
                if temp_mode == 'r':
                    file = open(path + 'resources/' + name, mode=temp_mode, encoding=encoding)
                else:
                    file = open(path + 'resources/' + name, mode=temp_mode)
                    
                return file
            except:
                pass

    #Simulate result from client by throwing file not found IOError
    #opening from no existent error        
    if file is None:
        open('project_or_lib_resources_folder/' + name)
            
    return file

def _build_manifest_file():
    ''' Read all projects in python path (paths that end with src) and
    build a simulated manifest.mf file based on files located
    in the resource directory relative to the src directory. 
    
    Project hierarchy if based on the order of the python path and may
    not match a VID file exactly in more complex setups
    '''
    paths = []
    file = None

    #build a list of projects to search based on python path 
    # and order of python path
    for path in sys.path:
        if path.endswith('\\src'):
            paths.append(path[:len(path)-3])

    # Build a simulated manifest.mf
    manifest = []
    project_path = ''
    for path in paths:
        try:

            #Get actual project name from .project file
            tree = ElementTree()
            proj_def = tree.parse(path+'.project');
            project_path += '|' + proj_def.find('name').text
            
            #get all files from resource directory and add to manifest list
            #if not already in list from previous project
            files = _get_files(path + 'resources\\')
            for file in files:
                #change file name to relative to resource directory
                file = file.replace(path + 'resources\\', '')
            
                #check if file name already exists
                exists = False
                for man in manifest:
                    if man.lower().startswith(file.lower()):
                        exists = True

                #if not already existing, then add it
                if not exists:
                    manifest.append(file + project_path)
        except:
            pass
    
    #Return StringIO object (to simulate file) of manifest
    return io.StringIO('\n'.join(manifest))

def get_vad_path():
    ''' return project's path 
    '''
    #try to find project relative to current working direcotry
    #if not found then just return current working directory
    vad_path = os.getcwd()
    for path in sys.path:
        if path.endswith('\\src'):
            temp_path = path[:len(path)-3]
            if vad_path.startswith(temp_path):
                vad_path = temp_path
                break
        
    return vad_path

def get_persistent_store_path():
    ''' return a temporary path location relative to project 
    '''
    persist_path = os.path.join(get_vad_path(), 'temp')
    if not os.access(persist_path, os.F_OK):
        os.makedirs(persist_path)
    return persist_path

def get_voice_application_property(name):
    ''' get a property from voiceconfig.xml in current project
    load all properties if not already loaded
    '''
    value = None
    global application_properties
    load_configuration()
    try:
        value = application_properties[name]
    except:
        value = None

    return value 

def get_all_voice_application_properties():
    global application_properties
    load_configuration()
    return application_properties

def getenvkeys():
    return environment_properties.keys()
    
def getenv(key, default_value = None):
    if key in environment_properties:
        return environment_properties[key]
    if default_value is not None and default_value != '':
        return default_value
    else:
        return key

def get_tts_properties():
    return user_tts_properties

def set_tts_properties(**kwargs):
    global user_tts_properties

    for key in kwargs:
        user_tts_properties[key] = kwargs[key]

def reset_tts_properties():
    global user_tts_properties
    global default_tts_properties
    
    for key in default_tts_properties:
        user_tts_properties[key] = default_tts_properties[key]

def start_noise_sample():
    
    if is_recognition_suppressed():
        raise RuntimeError('Attempted noise sample with recognition suppressed')
    
    if use_stdin_stdout:
        sys.stdout.write('<Noise Sample>\n')
        sys.stdout.flush()

def increase_volume():
    global user_tts_properties
    
    if user_tts_properties['volume'] < 9:
        msg = "Louder"
        user_tts_properties['volume'] = user_tts_properties['volume'] + 1
    else:
        msg = "Loudest"
        
    if use_stdin_stdout:
        sys.stdout.write('<' + msg + '>\n')
        sys.stdout.flush()

def decrease_volume():
    global user_tts_properties
    
    if user_tts_properties['volume'] > 1:
        msg = "Softer"
        user_tts_properties['volume'] = user_tts_properties['volume'] - 1
    else:
        msg = "Softest"
        
    if use_stdin_stdout:
        sys.stdout.write('<' + msg + '>\n')
        sys.stdout.flush()
    
def pause_processing():
    # Nothing to do; this is like 'Talkman sleep'    
    if use_stdin_stdout:
        print('<Good Night>\n')

def print_data(data_buffer, code_page=65001):
    # Just print the data to the console and call the callback
    # if registered.    
    if use_stdin_stdout:
        sys.stdout.write("Sent to printer: ")
        sys.stdout.flush()
        sys.stdout.buffer.write(data_buffer.encode())
        sys.stdout.write('\n')
        sys.stdout.flush()
        
    if EVENT_CB_MAPPING[str(voice.EVT_PRINT_COMPLETE_CB)]:
        #there no support right now to mock failures
        EVENT_CB_MAPPING[str(voice.EVT_PRINT_COMPLETE_CB)]("success")

def set_buttons_callback(button_callback):    
    global EVENT_CB_MAPPING
    EVENT_CB_MAPPING[str(voice.EVT_BUTTON_CB)] = button_callback

def set_locale_changed_callback(locale_callback):
    global EVENT_CB_MAPPING
    EVENT_CB_MAPPING[str(voice.EVT_LOCALE_CHANGED_CB)] = locale_callback
    
def set_print_complete_callback(print_callback):
    global EVENT_CB_MAPPING
    EVENT_CB_MAPPING[str(voice.EVT_PRINT_COMPLETE_CB)] = print_callback

def set_event_callback(callback, event_id):
    global EVENT_CB_MAPPING
    if event_id > 0 and event_id < 9:
        EVENT_CB_MAPPING[str(event_id)] = callback
    else:
        if use_stdin_stdout:
            sys.stdout.write(str(event_id) + ' is an invalid callback id')
            sys.stdout.flush()
        
def atunload_register(func):
    atexit.register(func)
    
def atunload_unregister(func):
    atexit.unregister(func)
    
def trigger_scanner(timeout_seconds):
    pass #does nothing in mock_catalyst since we do not have an A700 scanner

# 2.1.1 new API
def set_last_prompt(prompt_string):
    global _last_prompt
    # Don't put empty strings in here....
    if len(prompt_string) > 0:
        _last_prompt = prompt_string

def get_last_prompt():
    global _last_prompt
    return _last_prompt

def get_task_configuration():
    global _task_configuration
    return _task_configuration

################################################################
# Override voice objects
################################################################
sys.modules['voice'].Link = Link
sys.modules['voice'].Node = Node
sys.modules['voice'].Dialog = Dialog
sys.modules['voice'].open_vad_resource = open_vad_resource
sys.modules['voice'].log_message = log_message
sys.modules['voice'].get_persistent_store_path = get_persistent_store_path
sys.modules['voice'].get_vad_path = get_vad_path
sys.modules['voice'].get_voice_application_property = get_voice_application_property
sys.modules['voice'].get_all_voice_application_properties = get_all_voice_application_properties
sys.modules['voice'].current_dialog = current_dialog
sys.modules['voice'].get_all_vocabulary_from_vad = get_all_vocabulary_from_vad
sys.modules['voice'].set_scan_callback = set_scan_callback
sys.modules['voice'].getenvkeys = getenvkeys
sys.modules['voice'].getenv = getenv
sys.modules['voice'].set_tts_properties = set_tts_properties
sys.modules['voice'].get_tts_properties = get_tts_properties
sys.modules['voice'].reset_tts_properties = reset_tts_properties
sys.modules['voice'].start_noise_sample = start_noise_sample
sys.modules['voice'].decrease_volume = decrease_volume
sys.modules['voice'].increase_volume = increase_volume
sys.modules['voice'].pause_processing = pause_processing
sys.modules['voice'].print_data = print_data
sys.modules['voice'].set_event_callback = set_event_callback
sys.modules['voice'].set_buttons_callback = set_buttons_callback
sys.modules['voice'].set_locale_changed_callback = set_locale_changed_callback
sys.modules['voice'].set_print_complete_callback = set_print_complete_callback
sys.modules['voice'].trigger_scanner = trigger_scanner
sys.modules['voice'].set_last_prompt = set_last_prompt
sys.modules['voice'].get_last_prompt = get_last_prompt
sys.modules['voice'].get_task_configuration = get_task_configuration

sys.modules['_voice'].initialize_dialog = initialize_dialog
sys.modules['_voice'].clean_up_dialog = clean_up_dialog

sys.modules['voice.audio'].beep = beep
sys.modules['voice.audio'].play = play
sys.modules['voice.audio'].stop_playing = stop_playing
sys.modules['voice.audio'].start_recording = start_recording
sys.modules['voice.audio'].stop_recording = stop_recording
sys.modules['voice.recognition'].is_recognition_suppressed = is_recognition_suppressed
sys.modules['voice.recognition'].get_number_of_untrained_templates = get_number_of_untrained_templates 
sys.modules['voice.recognition'].set_suppress_recognition = set_suppress_recognition 
sys.modules['voice.recognition'].set_training_done_callback = set_training_done_callback 
sys.modules['voice.atunload'].register = atunload_register
sys.modules['voice.atunload'].unregister = atunload_unregister



#=================================================================
# Helper method for executing on entry and conditional function
#=================================================================
def execute_method(command):
    return eval(command + '()', global_modules)


#=================================================================
# Initialization methods for loading VID files in to templates
#=================================================================
def _open_vad_file(name, mode = 'r', encoding='utf-8'):
    """Open a resource file within the VAD for currently running voice
    application.
    """
    # translate mode to be similar to open()'s mode (but limited to
    # read-only modes)
    if mode == 'r' or mode == 'rt':
        zip_open_mode = 'rU'
    elif mode == 'rb':
        zip_open_mode = 'r'
    else:
        raise ValueError('Illegal mode')

    vad = zipfile.ZipFile(__vad_file, 'r')
    contents = vad.open(name, zip_open_mode)
    if 'b' in mode:
        return contents
    return voice._DecodedZipExtFile(contents, encoding)
            

def _get_files(path):
    ''' method to get all files in directory and sub directories '''
    
    files = []
    #check if path exists
    if os.path.exists(path): #@UndefinedVariable
        temp=os.listdir(path)
        for a in temp:
            try:
                if os.path.isfile(path+a): #@UndefinedVariable
                    files.append(path+a)
                if os.path.isdir(path+a): #@UndefinedVariable
                    files.extend(_get_files(path+a+'\\'))
            except:
                pass
    
    return files


#=================================================================
# Load dialog templates
#=================================================================
def load_dialog_from_project():
    ''' Load dialog definitions from VID files of projects
    '''
    for path in sys.path:
        if path.endswith('\\src'):
            #only look in dialogs folder of main project
            files = _get_files(path[:len(path)-3]+'dialogs\\')
            for file in files:
                if file.endswith('.vid'):
                    _parse_vid(file)

def _parse_vid(file):
    ''' parse a VID file '''
    global all_vocab
    
    tree = ElementTree()
    vid_dom = tree.parse(file).findall('{http:///com/vocollect/voiceartisan/dialog.ecore}Dialog')
    
    #create dialog
    dialog = Dialog()
    dialog.name = file.split('\\')[-1][0:-4]
    dialog._start_node = vid_dom[0].attrib['startNode']

    #temporary dictionary for finding nodes by GMF id
    nodes = {}
    
    #create nodes
    children = vid_dom[0].findall('nodes')
    for vid_node in children:
        node = Node(vid_node.attrib['name'])
        
        if 'prompt' in vid_node.attrib: node.prompt = vid_node.attrib['prompt']
        if 'helpPrompt' in vid_node.attrib: node.help_prompt = vid_node.attrib['helpPrompt']
        if 'methodName' in vid_node.attrib: node.on_entry_method = vid_node.attrib['methodName']
        if 'priorityPrompt' in vid_node.attrib: node.prompt_is_priority = vid_node.attrib['priorityPrompt'] == 'true'
        
        dialog.nodes[node.name] = node
        nodes[vid_node.attrib['{http://www.omg.org/XMI}id']] = node.name
        node.dialog = dialog
    
    #change start node to proper name
    dialog._start_node = nodes[dialog._start_node]
    
    #create links
    children = vid_dom[0].findall('links')
    for vid_link in children:
        vocabulary = vid_link.findall('vocabulary')
        vocab_list = []
        for vocab in vocabulary:
            vocab_list.append(vocab.text)
            if vocab.text not in all_vocab:
                all_vocab.append(vocab.text)

        link = Link(vid_link.attrib['name'], 
                    dialog.nodes[nodes[vid_link.attrib['originNode']]], 
                    dialog.nodes[nodes[vid_link.attrib['destinationNode']]], 
                    vocab_list)

        if 'methodName' in vid_link.attrib: link._conditional_method = vid_link.attrib['methodName']
        if 'executionOrder' in vid_link.attrib: link.execution_order = int(vid_link.attrib['executionOrder'])
        if 'echo' in vid_link.attrib: link.link_is_echo = vid_link.attrib['echo'] == 'true'
        link.dialog = dialog
        
        dialog.links[link.name] = link
    
    #only add to template if not already added.
    if dialog.name not in dialog_templates:
        dialog_templates[dialog.name] = dialog
    
def load_dialog_from_vad():
    ''' Load dialog definitions from application xml file in VAD
    '''
    f = _open_vad_file('application.xml', 'rb')
    tree = ElementTree()
    dialogs = tree.parse(f).findall("dialog");
    for dialog in dialogs:
        #create dialog
        d = Dialog()
        d.name = dialog.attrib['name']
        startNode = dialog.findall('startNode')
        for node in startNode: #should only be 1
            d._start_node = node.attrib['id']

        #Add nodes            
        node_to_id = {}
        for node in dialog.findall('node'):
            n = Node(node.attrib['name'])
            for child in node.getchildren():
                if child.tag == 'prompt':
                    n.prompt = child.attrib['value']
                    n.prompt_is_priority = child.attrib['priority'] == 'true' 
                elif child.tag == 'method':
                    n.on_entry_method = child.attrib['name']
                elif child.tag == 'helpPrompt':
                    n.help_prompt = child.attrib['value']
            
            d.nodes[n.name] = n
            node_to_id[node.attrib['id']] = n.name
            n.dialog = d
        
        #change start node to proper name
        d._start_node = node_to_id[d._start_node]
        
        #add default links
        for link in dialog.findall('linkDefault'):
            l = Link(link.attrib['name'], 
                     d.nodes[node_to_id[link.attrib['sourceNode']]], 
                     d.nodes[node_to_id[link.attrib['destinationNode']]])
            l.dialog = d
            d.links[l.name] = l
            
        #add conditional links
        order_from_node = {}
        for link in dialog.findall('linkConditional'):
            cond_method = ''
            for child in link.getchildren():
                if child.tag == 'method':
                    cond_method = child.attrib['name']
            
            l = Link(link.attrib['name'], 
                     d.nodes[node_to_id[link.attrib['sourceNode']]], 
                     d.nodes[node_to_id[link.attrib['destinationNode']]], 
                     conditional_method=cond_method)

            if link.attrib['sourceNode'] not in order_from_node:
                order_from_node[link.attrib['sourceNode']] = 1
                
            l.execution_order = order_from_node[link.attrib['sourceNode']]
            order_from_node[link.attrib['sourceNode']] += 1
            
            l.dialog = d
            d.links[l.name] = l
            
        #add vocabulary links
        for link in dialog.findall('linkVocabulary'):
            vocab_list = []
            for child in link.getchildren():
                if child.tag == 'vocabulary':
                    vocab_list.append(child.text)
                    if child.text not in all_vocab:
                        all_vocab.append(child.text)

            l = Link(link.attrib['name'], 
                     d.nodes[node_to_id[link.attrib['sourceNode']]], 
                     d.nodes[node_to_id[link.attrib['destinationNode']]], 
                     vocab_list)
                
            l.dialog = d
            d.links[l.name] = l
            
        #only add to template if not already added.
        if d.name not in dialog_templates:
            dialog_templates[d.name] = d
        

#=================================================================
# Load vocabulary
#=================================================================
def load_vocabulary_from_project():
    ''' load additional and global vocabulary from voiceconfig.xml '''
    global all_vocab

    #Start in current working directory and work our way up 
    #until we find an voiceconfig.xml
    found = False
    path = os.getcwd()
    while not found and len(path) > 4:
        try:
            f = open(os.path.join(path, 'voiceconfig.xml'), 'rb') #@UndefinedVariable
            found = True
       
            application_properties = {}
            tree = ElementTree()
            v1 = tree.parse(f).findall("vocabulary");
            v2 = v1[0].findall('vocab')
            all_words = {}
            for vocab in v2:
                word = vocab.attrib['word']
                if word not in all_vocab:
                    all_vocab.append(word) 
                
                if 'function' in vocab.attrib:
                    all_words[word] = MockGlobalWord(word, vocab.attrib['function'], vocab.attrib['enabled'] == 'true', vocab.attrib['echo'] == 'true')

            f.close()
            voice.globalwords.words = voice.globalwords.GlobalVocabulary(all_words)
        except:
            path = os.path.split(path)[0] #@UndefinedVariable

def load_vocabulary_from_vad():
    ''' load additional and global vocabulary from voiceconfig.xml '''
    global all_vocab

    #Running a VAD File so look in file for name
    f = _open_vad_file('application.xml', 'rb')
    tree = ElementTree()
    properties = tree.parse(f).findall("vocabulary");
    all_words = {}
    for property in properties:
        word = property.attrib['word']
        if word not in all_vocab:
            all_vocab.append(word) 
        
        if 'function' in property.attrib and property.attrib['function'] != '':
            all_words[word] = MockGlobalWord(word, 
                                             property.attrib['function'], 
                                             property.attrib['enabled'] == 'true', 
                                             property.attrib['echo'] == 'true')

    f.close()
    voice.globalwords.words = voice.globalwords.GlobalVocabulary(all_words)
    
    
#=================================================================
# Load application properties
#=================================================================
def load_application_property_from_vad():
    ''' load all properties from voiceconfig.xml in current project
    load all properties if not already loaded
    '''
    global application_properties
    application_properties = {}

    #Running a VAD File so look in file for name
    f = _open_vad_file('config.xml', 'rb')
    tree = ElementTree()
    properties = tree.parse(f).findall("group");
    for property in properties:
        if property.attrib['name'] == 'properties':
            prop = property.getiterator("descriptor-entry")
            for p in prop:
                name = p.attrib['name']
                for child in p.getchildren():
                    if child.tag == 'value':
                        application_properties[name] = child.text
                        
    f.close()


def _project_depth(project, depth):
    
    #set the lowest depth
    if depth < __proj_refs[project][1]:
        __proj_refs[project][1] = depth
    
    #recursively call for all project it references
    for proj in __proj_refs[project][2]:
        _project_depth(proj, depth+1)

def _get_project_paths():
    #get a list of directories that are eclipse projects (have \src folder)
    paths = []
    for path in sys.path:
        if path.endswith('\\src'):
            paths.append(path[:len(path)-3])

    #load all the .project files (name = key, list = referenced projects) 
    for path in paths:
        tree = ElementTree()
        proj_def = tree.parse(path+'.project');
        __proj_refs[proj_def.find('name').text] = [path, 1000000, []]
        projs = tree.findall('projects')[0].findall('project')
        for proj in projs:
            __proj_refs[proj_def.find('name').text][2].append(proj.text)
            
    #get main project - it should be the only one that no other project references
    for lib in __proj_refs:
        found = False
        for temp in __proj_refs:
            if lib in __proj_refs[temp][2]:
                found = True
                
        if not found:
            __main_proj = lib
    
    _project_depth(__main_proj, 0)
    
    #determine how deep projects go
    max_depth = 0
    for key in __proj_refs:
        max_depth = __proj_refs[key][1] if __proj_refs[key][1] > max_depth else max_depth

    #now working from the lowest level, build a list of project paths up to the main project
    sorted_paths = []
    while max_depth >= 0:
        for key in __proj_refs:
            if __proj_refs[key][1] == max_depth:
                sorted_paths.append(__proj_refs[key][0])
        max_depth = max_depth - 1

    return sorted_paths    

def load_application_property_from_project():
    ''' load all properties from voiceconfig.xml in current project as well as referenced projects
    load all properties if not already loaded
    '''
    global application_properties
    application_properties = {}

    # Get the project paths based upon the .project file references
    paths = _get_project_paths()
    
    #search each project found until specified file is found
    for path in paths:
        found = False
        while not found and len(path) > 4:
            try:
                f = open(os.path.join(path, 'voiceconfig.xml'), 'rb') #@UndefinedVariable
                found = True
           
                tree = ElementTree()
                properties = tree.parse(f).findall("properties");
                for property in properties:
                    prop = property.getiterator("property")
                    for p in prop:
                        application_properties[p.attrib["name"]] = p.attrib.get("value", "")
                f.close()
            except:
                path = os.path.split(path)[0] #@UndefinedVariable

def load_task_configuration_from_project():
    ''' create a config.xml content document
    '''
    global _task_configuration
    _task_configuration = ""

    root = Element('vad-descriptor')
    version = SubElement(root, 'descriptor-version')
    version.text = "1.0"
    
    config_properties = SubElement(root, 'group', {'name': 'properties'})
    config_phonetics = SubElement(root, 'group', {'name' : 'phonetic'})
    config_embedded = SubElement(root, 'group', {'name' : 'embedded-training'})
    config_settings = SubElement(root, 'group', {'name' : 'device-settings'})

    # Get the project paths based upon the .project file references
    paths = _get_project_paths()
    
    #search each project found until specified file is found
    for path in paths:
        found = False
        while not found and len(path) > 4:
            try:
                f = open(os.path.join(path, 'voiceconfig.xml'), 'rb') #@UndefinedVariable
                found = True
           
                tree = ElementTree()
                
                #
                # Properties
                #
                properties = tree.parse(f).findall("properties")
                for property in properties:
                    prop = property.getiterator("property")
                    for p in prop:
                        new_prop = SubElement(config_properties, 'descriptor-entry', {'name' : p.attrib["name"]})
                        type = SubElement(new_prop, 'type')
                        type.text = p.attrib.get('type')
                        v = SubElement(new_prop, 'value')
                        v.text = p.attrib.get("value", "")
 
                #
                # Phonetics
                # First for loop is organize the phonetics into groupings by locale
                # Second for loop is to then add each locale as its own SubElement
                # and then add the phonetics into that locale subelement
                #
                f.seek(0)
                temp_phonetics = {}
                phonetics = tree.parse(f).findall("phoneticSubstitutions")
                for phonetic in phonetics:
                    curr_local_phon = None
                    phon = phonetic.getiterator("phonetic")
                    current_locale = ""
                    for p in phon:
                        if p.attrib["locale"] not in temp_phonetics:
                            temp_phonetics[p.attrib["locale"]] = []
                        
                        temp_phonetics[p.attrib['locale']].append({'phrase': p.attrib.get('phrase'),
                                                                  'substitution' : p.attrib.get('substitution'),
                                                                  'display' : p.attrib.get('display')})

                for locale in temp_phonetics:
                    curr_local_phon = SubElement(config_phonetics, 'locale', {'name': locale})
                    
                    for p in temp_phonetics[locale]:
                        curr_phon = SubElement(curr_local_phon, 'phonetic', {'phrase': p['phrase'],
                                                                             'substitution': p['substitution'],
                                                                            'display': p['display']})

                #
                # Embedded Training
                #
                f.seek(0)
                embeddeds = tree.parse(f).findall("embeddedTraining")
                for embbed in embeddeds:
                    phrases = embbed.getiterator("phrase")
                    for phrase in phrases:
                        curr_phrase = SubElement(config_embedded, 'phrase')
                        words = phrase.getiterator("word")
                        for word in words:
                            this_word = SubElement(curr_phrase, 'word')
                            this_word.text = word.text
                        
                #
                # Device Settings
                #
                f.seek(0)
                
                settings = tree.parse(f).findall("deviceSettings")
                for setting in settings:
                    prop = setting.getiterator("property")
                    for p in prop:
                        new_prop = SubElement(config_settings, 'freeform-entry', {'name' : p.attrib["name"]})
                        v = SubElement(new_prop, 'value')
                        v.text = p.attrib.get("value", "")
    
                f.close()

            except:
                print( "Unexpected error:", sys.exc_info()[0])
                path = os.path.split(path)[0] #@UndefinedVariable
    
    _task_configuration = tostring(root, encoding='utf-8').decode('utf-8')
    
def load_modules():
    ''' load modules called from node on entry method, conditional link methods
        and from global words. Load the main module before any of them to
        make import order more predictable for customizations. The Catalyst
        runtime is planning to do this in 1.1
    '''
    global dialog_templates, global_modules
    modules = set([])
    for word in list(voice.globalwords.words.values()):
        modules.add(word.target.split('.')[0])

    for dialog in list(dialog_templates.values()):
        for node in list(dialog.nodes.values()):
            if node.on_entry_method is not None and node.on_entry_method != '':
                modules.add(node.on_entry_method.split('.')[0])
        
        for link in list(dialog.links.values()):
            if link.conditional_method is not None and link.conditional_method != '':
                modules.add(link.conditional_method.split('.')[0])
    
    # This has to be the first loaded module, but may not exist for all project/libraries
    try:            
        global_modules['main'] = __import__('main')
    except:
        #simply ignore for now when main cannot be loaded.
        pass
                
    for module in modules:
        global_modules[module] = __import__(module)

def load_override_properties():
    '''Load override properties, call from running VAD file only    
    '''
    try:
        print('Loading properties:')
        from configparser import RawConfigParser
        cp = RawConfigParser()
        cp.read('./properties.ini')
        for section in cp.sections():
            for property in cp.get(section, 'properties').split('\n'):
                values = property.split(',')
                if len(values) == 2 and values[1] not in [None, '']:
                    if section == 'Application': 
                        application_properties[values[0]] = values[1]
                        print('\tSetting Application property %s = %s' % (values[0], values[1]))
                    if section == 'Environment': 
                        environment_properties[values[0]] = values[1]
                        print('\tSetting Environment property %s = %s' % (values[0], values[1]))
        print()
    except:
        pass

#Old method of loading application properties
def _load_application_property():
    ''' DEPRECATED!  Use load_configuration() 
    load all properties from voiceconfig.xml in current project
    load all properties if not already loaded
    '''
    load_configuration()

#load config.xml into a string variable
def load_task_configuration_from_vad():
    global _task_configuration
    _task_configuration = ''

    #Running a VAD File so look in file for name
    f = _open_vad_file('config.xml', 'r')
    #read each line and strip linefeeds and white spaces
    _task_configuration = "".join(line.rstrip() for line in f)

#create a config.xml document and then stringify it
def load_task_configuration():
    global _task_configuration
    #build xml document
    #
    _task_configuration = ''
    
#-------------------------------------------------------------------------
#Load and configure mock_catalyst mock ups
def load_configuration():
    global __loaded, __running_vad, __vad_file
    if not __loaded:
        __loaded = True
        
        #check if running a VAD file
        __vad_file = './run.vad'
        if len(sys.argv) > 1:
            __vad_file = sys.argv[1]

        try:
            temp = zipfile.ZipFile(__vad_file, 'r')
            __running_vad = True
        except:
            __running_vad = False
        finally:
            #Make sure temp file is closed if it was opened
            try:
                temp.close()
            except:
                pass
                    
        if __running_vad:
            sys.path.append(os.path.join(__vad_file, 'python'))

            print('\nEnter values for the given prompts')
            print('For "ready" you may just press enter')
            print('Enter a dash (-) to end application\n ')

            load_application_property_from_vad()
            load_dialog_from_vad()
            load_vocabulary_from_vad()
            load_override_properties()
            load_task_configuration_from_vad()
            
        else:
            load_application_property_from_project()
            load_dialog_from_project()
            load_vocabulary_from_project()
            load_task_configuration_from_project()
        
        load_modules()
        
load_configuration()
