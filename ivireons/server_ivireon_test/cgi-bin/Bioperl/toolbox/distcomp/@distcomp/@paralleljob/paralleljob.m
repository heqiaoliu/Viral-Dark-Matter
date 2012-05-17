function obj = paralleljob( proxyJob )
; %#ok Undocumented
    
%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.4 $    $Date: 2007/06/18 22:13:43 $

obj = distcomp.paralleljob;
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
