%EVENT.PROPLISTENER    Listener object for property events
%    The EVENT.PROPLISTENER class is a subclass of EVENT.LISTENER and
%    defines listener objects for property events.  Property listener 
%    objects listen for an event on a specific property and identify the 
%    callback function to invoke when the event is triggered.
%    
%    EL = EVENT.PROPLISTENER(OBJ,Properties,'PropEvent',@CallbackFunction)
%    creates a listener object for one or more properties on the 
%    specified object.  The input parameter Properties must be an object 
%    array or cell array of meta.property handles.  'PropEvent' must be 
%    one of 'PreSet', 'PostSet', 'PreGet', or 'PostGet'.  The fourth 
%    argument is a function handle to the event callback function.  If OBJ 
%    is an array of handle objects, the listener responds to the named 
%    event on any object in the array.
%
%    Property event listeners can also be created using ADDLISTENER.
%
%    See also EVENT.LISTENER, HANDLE.ADDLISTENER, HANDLE.NOTIFY, 
%    EVENT.EVENTDATA

%   Copyright 2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2008/09/15 20:39:26 $
%   Built-in class.