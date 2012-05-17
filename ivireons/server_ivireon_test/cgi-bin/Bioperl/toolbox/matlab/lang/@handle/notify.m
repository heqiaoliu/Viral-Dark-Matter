%NOTIFY   Notify listeners of event.
%   NOTIFY(H,'EVENTNAME') notifies listeners added to the event named 
%   EVENTNAME on handle object array H that the event is taking place.  
%   H is the array of handles to objects triggering the event, and 
%   EVENTNAME must be a string.
%
%   NOTIFY(H,'EVENTNAME',DATA) provides a way of encapsulating information 
%   about an event which can then be accessed by each registered listener.
%   DATA must belong to the EVENT.EVENTDATA class.
%
%   See also HANDLE, HANDLE/ADDLISTENER, EVENT.EVENTDATA, EVENTS
 
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2008/03/24 18:09:09 $
%   Built-in function.



