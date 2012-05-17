function h = BuildInProgress(mdl)
% This objecte is responsible for gating model compilation status and 
% broadcasting events for model building


% Copyright 2004-2009 The MathWorks, Inc.

    h = Simulink.BuildInProgress;
    h.ModelName = mdl;
    
    % set the BuildInProgress flag on
    if ~isempty(find(slroot,'-isa','Simulink.BlockDiagram','Name',h.ModelName))
        h.ModelObj = get_param(mdl, 'Object');
        set_param(h.ModelName, 'BuildInProgress', 'on');
        ed = DAStudio.EventDispatcher;
        ed.broadcastEvent('ReadonlyChangedEvent', h.ModelObj, '');
        ed.broadcastEvent('MESleepEvent', [], ['building ' h.ModelName]);

        % add listener to reset BuildInProgress on object destruction
        h.Listener = handle.listener(h, 'ObjectBeingDestroyed', @reset);
    end
end

function reset(h, event, varargin)
% reset the BuildInProgress flag
    ed = DAStudio.EventDispatcher;
    ed.broadcastEvent('MEWakeEvent');
    if ~isempty(find(slroot,'-isa','Simulink.BlockDiagram','Name',h.ModelName))
        set_param(h.ModelName, 'BuildInProgress', 'off');
        ed.broadcastEvent('ReadonlyChangedEvent', h.ModelObj, '');
    end 
end
