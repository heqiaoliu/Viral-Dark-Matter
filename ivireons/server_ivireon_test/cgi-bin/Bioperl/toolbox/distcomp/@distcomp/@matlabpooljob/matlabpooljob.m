function obj = matlabpooljob( proxyJob )
; %#ok Undocumented

% Copyright 2007 The MathWorks, Inc.

% $Revision: 1.1.6.1 $    $Date: 2007/10/10 20:41:16 $

obj = distcomp.matlabpooljob;
% Call any inherited constructors
proxyobject(obj, proxyJob);
% Create the EventListeners that will drive the callbacks from this
% object - see the method pSetCallbacks for interactions with these
% listeners
obj.CallbackListeners = [...
    handle.listener(obj, 'PostQueue', '');...
    handle.listener(obj, 'PostRun', '');...
    handle.listener(obj, 'PostFinish', '');...
    handle.listener(obj, 'TaskPostCreate', '');...
    handle.listener(obj, 'TaskPostRun', '');...
    handle.listener(obj, 'TaskPostFinish', '');...
    ];
set(obj.CallbackListeners, 'enable', 'off', 'CallbackTarget', obj);

% This class accepts configurations and uses the paralleljob section.
sectionName = 'paralleljob';
obj.pInitializeForConfigurations(sectionName);
