function obj = job(proxyJob)
; %#ok Undocumented
%JOB A short description of the function
%
%  OBJ = JOB(PROXYJOB)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.6 $    $Date: 2008/06/24 17:01:17 $

obj = distcomp.job;
% Call any inherited constructors
proxyobject(obj, proxyJob);
% Create the EventListeners that will drive the callbacks from this
% object - see the method pSetCallbacks for interactions with these
% listeners
obj.CallbackListeners = [...
    handle.listener(obj, 'PostQueue', '');...
    handle.listener(obj, 'PostRun', '');...
    handle.listener(obj, 'PostFinish', '');...
    ];
set(obj.CallbackListeners, 'enable', 'off', 'CallbackTarget', obj);

% This class accepts configurations and uses the job section.
sectionName = 'job';
obj.pInitializeForConfigurations(sectionName);

% End of constructor
end
