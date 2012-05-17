%EVENT.LISTENER    Listener object
%    The EVENT.LISTENER class defines listener objects.  Listener objects
%    listen for a specific event and identify the callback function to 
%    invoke when the event is triggered.
%    
%    EL = EVENT.LISTENER(OBJ,'EventName',@CallbackFunction) creates a 
%    listener object for the event named 'EventName' on the specified 
%    object and specifies a function handle to the callback function.  If 
%    OBJ is an array of objects, the listener responds to the named event
%    on any handle in the array.
%
%    The listener callback function must be defined to accept at least two
%    input arguments, as in: 
%        function CallbackFunction(SOURCE, EVENTDATA)
%        ...
%        end
%    where SOURCE is the object that is the source of the event and
%    EVENTDATA is an EVENT.EVENTDATA instance.
%
%    Event listeners can also be created using ADDLISTENER.
%
%    See also HANDLE.ADDLISTENER, HANDLE.NOTIFY, EVENT.EVENTDATA

%   Copyright 2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2008/03/24 18:08:46 $
%   Built-in class.