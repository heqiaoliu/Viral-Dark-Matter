function save(configName, newValues)
; %#ok Undocumented
% saves values and associates them with a configuration

%   Copyright 2007 The MathWorks, Inc.
    
ser = distcomp.configserializer.pGetInstance();
% pGetID throws an error if configName is invalid.
ID = ser.pGetID(configName);
% Get the current values of the configuration for use in nUndo.
oldValues = ser.Cache.configurations(ID).Values;

currAction = com.mathworks.toolbox.distcomp.configurations.ConfigUndoAction.SAVE;
action = struct('redo', @nRedo, ...
                'undo', @nUndo, ...
                'action', currAction, ...
                'config', configName);
action.redo();
ser.pAddUndoAction(action);

    function nRedo() 
    % Sets configName to newValues.
    nser = distcomp.configserializer.pGetInstance();
    nser.pSave(configName, newValues)
    end

    function nUndo() 
    % Sets configName to oldValues 
    nser = distcomp.configserializer.pGetInstance();    
    nser.pSave(configName, oldValues);
    end

end
