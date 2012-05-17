function abstractjobqueue(obj, proxyQueue)
; %#ok Undocumented
%Protected constructor for abstractjobqueue matlab objects that is called by
%findresource to create appropriate objects

% Copyright 2004-2006 The MathWorks, Inc.

% Call inherited constructor - no adaptor yet - strangely this call seems
% to need to be made like this and not obj.proxyobject. I am unsure why
% this is
proxyobject(obj, proxyQueue);

% Create the EventListeners that will drive the callbacks from this object
obj.CallbackListeners = [...
    handle.listener(obj, 'JobPostQueue', '');...
    handle.listener(obj, 'JobPostRun', '');...
    handle.listener(obj, 'JobPostFinish', '');...
    ];

set(obj.CallbackListeners, 'enable', 'off', 'CallbackTarget', obj);

