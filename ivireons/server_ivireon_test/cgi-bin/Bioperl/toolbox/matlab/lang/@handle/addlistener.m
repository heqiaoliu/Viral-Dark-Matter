%ADDLISTENER   Add listener for event.
%   EL = ADDLISTENER(HSOURCE, 'EVENTNAME', CALLBACK) creates a listener
%   for the event named EVENTNAME, the source of which is handle object 
%   HSOURCE.  If HSOURCE is an array of source handles, the listener
%   responds to the named event on any handle in the array.  CALLBACK
%   is a function handle that is invoked when the event is triggered.
%
%   EL = ADDLISTENER(HSOURCE, PROPERTY, 'EVENTNAME', CALLBACK) adds a 
%   listener for a property event.  EVENTNAME must be one of the strings 
%   'PreGet', 'PostGet', 'PreSet', and 'PostSet'.  PROPERTY must be either
%   a property name or cell array of property names, or a META.PROPERTY 
%   or array of META.PROPERTY.  The properties must belong to the class of 
%   HSOURCE.  If HSOURCE is scalar, PROPERTY can include dynamic 
%   properties.
%   
%   For all forms, ADDLISTENER returns an EVENT.LISTENER.  To remove a
%   listener, delete the object returned by ADDLISTENER.  For example,
%   DELETE(EL) calls the handle class delete method to remove the listener
%   and delete it from the workspace.
%
%   See also HANDLE, HANDLE/NOTIFY, HANDLE/DELETE, EVENT.LISTENER, 
%   META.PROPERTY, EVENTS, DYNAMICPROPS
 
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2008/04/06 19:16:34 $
%   Built-in class method.



