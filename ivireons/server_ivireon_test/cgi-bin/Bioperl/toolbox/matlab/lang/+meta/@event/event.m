%META.EVENT    Describe an event of a MATLAB class
%    The META.EVENT class contains descriptive information about 
%    methods of MATLAB classes.  Properties of a META.EVENT instance 
%    correspond to attributes of the class event being described.  
%
%    All META.EVENT properties are read-only.  The META.EVENT
%    instance can be queried to obtain information about the class
%    event it describes.  All information about class events are
%    specified in the class definition for the class to which the event 
%    belongs.
%
%    Obtain a META.EVENT instance from the EVENTS property of the
%    META.CLASS instance.  EVENTS is a cell array of META.EVENT
%    instances, one per class event.
%
%    %Example 1
%    %Display the properties of a META.EVENT instance
%    mc = ?handle;
%    mevents = mc.Events;
%    properties(mevents{1});
%
%    %Example 2
%    %Use the DEFININGCLASS property of META.EVENT to obtain the
%    %META.CLASS for the class to which the event belongs.
%    mc = ?handle;
%    mevents = mc.Events;
%    mc2 = mevents{1}.DefiningClass;
%    mc == mc2
%    
%    See also META.CLASS, META.PROPERTY, META.METHOD

%   Copyright 2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2008/03/24 18:08:50 $
%   Built-in class.