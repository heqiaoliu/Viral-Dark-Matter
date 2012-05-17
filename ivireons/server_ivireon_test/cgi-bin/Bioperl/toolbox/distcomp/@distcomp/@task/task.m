function obj = task(proxyTask)
; %#ok Undocumented
%TASK A short description of the function
%
%  OBJ = TASK(PROXYOBJECT)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2007/06/18 22:14:06 $ 

obj = distcomp.task;
% Normal construction would have proxyTask correctly set - the zero argument
% constructor is used to fill a dummy task with a TaskInfo object for use in
% task construction.
if nargin > 0 
    % Call any inherited constructors
    proxyobject(obj, proxyTask);
end
% Create the EventListeners that will drive the callbacks from this
% object - see the method pSetCallbacks for interactions with these
% listeners
obj.CallbackListeners = [...
    handle.listener(obj, 'PostRun', '');...
    handle.listener(obj, 'PostFinish', '');...
    ];

% Might implement these in the future
%     handle.listener(obj, 'PostQueue', '');...
%     handle.listener(obj, 'TaskPostCreate', '');...
%     handle.listener(obj, 'TaskPostRun', '');...
%     handle.listener(obj, 'TaskPostFinish', '');...

set(obj.CallbackListeners, 'enable', 'off', 'CallbackTarget', obj);

% This class accepts configurations and uses the task section.
sectionName = 'task';
obj.pInitializeForConfigurations(sectionName);
