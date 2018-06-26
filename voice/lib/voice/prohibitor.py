"""Classes for use when tracking whether a certain arbitrary operation is prohibited or allowed."""


import threading

class Prohibitor(object):
    def __init__(self):
        """Create a Prohibitor.  
        
        Initially, the object's is_allowed() method will return True.  Note that the Prohibitor can 
        be manipulated via its prohibit() and allow() methods or it can be used in a with statement; 
        upon entry to the with statement's suite the prohibit() method is invoked, and upon exit the 
        allow() method is invoked.  All operations taken on a given Prohibitor object are thread-
        safe.
        """
        self.__data_lock = threading.RLock()
        self.__callback_lock = threading.RLock()
        self.__prohibit_count = 0
        self.__callback = None
        self.__thaw_event = threading.Event()
        self._thaw()
    
    def prohibit(self):
        """Add a prohibition to this Prohibitor.

        Prohibits are counted.  If two prohibit() calls are made on the same Prohibitor, two
        corresponding allow() calls must be made before the Prohibitor's is_allowed() method returns
        True and any registered callbacks are invoked.  Note that this function blocks until
        this object has been "thawed"
        
        """
        with self.__data_lock:
            self.__thaw_event.wait()
            self.__prohibit_count += 1
        
    def allow(self):
        """Remove a prohibition from this Prohibitor.

        Prohibits are counted.  If two prohibit() calls are made on the same Prohibitor, two
        corresponding allow() calls must be made before the Prohibitor's is_allowed() method returns 
        True and any registered callbacks are invoked.  Note that prohibits and allows must be 
        balanced; an allow() call when the object's is_allowed() method is already returning True 
        will raise a RuntimeError.  Note that this function blocks until this object has 
        been "thawed"
        """
        with self.__data_lock:
            self.__thaw_event.wait()
            self.__verify_prohibit_count_is_not_zero()
            self.__prohibit_count -= 1
            self.__invoke_callback_if_necessary()
                
    def is_allowed(self):
        """Determine if the operation controlled by this Prohibitor is allowed."""
        with self.__data_lock:
            return self.__prohibit_count == 0

    def _notify_when_allowed(self, callback):
        """Register a callback for notification when this Prohibitor allows operations.
        
        If is_allowed() will currently return True, the callback will be invoked immediately as part 
        of the call to notify_when_allowed().  If is_allowed() will currently return False, the 
        callback will be stored and invoked when a subsequent allow() call reduces the prohibit
        count to zero.  One one callback can be stored at a time.  The callback is not cleared upon 
        invocation; to remove the callback, invoke remove_notification().
        """
        with self.__callback_lock:
            self.__verify_callback_is_valid(callback)
            self.__store_callback(callback)
            self.__invoke_callback_if_necessary()

    def _remove_notification(self, callback):
        """Unregister a callback from notification when this Prohibitor allows operations.
        We thaw this class when we remove the callback.  There is no point keeping this class
        frozen unless we have a callback (the freeze/thaw mechanism is to make sure the class state
        doesn't change until the callback owner has a chance to handle the state change that initiated
        the callback.  Also, we want to prevent this class from being stuck in the "frozen" state
        after the callback is removed, since the owner of the callback is the one who "thaws" this
        class [VCPC-160 in JIRA].
        """
        with self.__callback_lock:
            if callback != self.__callback:
                raise RuntimeError("Invalid operation with untracked callback")
            else:
                self.__callback = None
                self._thaw()
                
    def _freeze(self):
        self.__thaw_event.clear()
        
    def _thaw(self):
        self.__thaw_event.set()
        
    def __enter__(self):
        self.prohibit()
        
    def __exit__(self, exc_type, exc_value, exc_traceback):
        self.allow()
        
    def __verify_prohibit_count_is_not_zero(self):
        if self.__prohibit_count == 0:            
            raise RuntimeError("Invalid operation with non-zero prohibit count")
        
    def __verify_callback_is_valid(self, callback):
        if not callback or not hasattr(callback, '__call__'):
            raise RuntimeError("Invalid callback")
        
    def __store_callback(self, callback):
        with self.__callback_lock:
            if self.__callback == None:
                self.__callback = callback
            else:
                raise RuntimeError("Invalid operation: callback already exists")
        
    def __invoke_callback_if_necessary(self):
        with self.__callback_lock:
            if self.is_allowed():
                if self.__callback != None:
                    self._freeze()
                    self.__callback()
