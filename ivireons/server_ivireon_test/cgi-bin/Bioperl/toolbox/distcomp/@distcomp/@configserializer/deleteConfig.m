function deleteConfig(configName)
; %#ok Undocumented
%Static method that deletes the specified configuration.
%   Throws an error if the configuration doesn't exist.

%   Copyright 2007 The MathWorks, Inc.

ser = distcomp.configserializer.pGetInstance();
% Get the configuration values and the current config for use in nRedo and
% nUndo.
orgValues = ser.Cache.configurations(ser.pGetID(configName)).Values;
orgCurrent = ser.Cache.current;

currAction = com.mathworks.toolbox.distcomp.configurations.ConfigUndoAction.DELETE;
action = struct('redo', @nRedo, ...
                'undo', @nUndo, ...
                'action', currAction, ...
                'config', configName);
action.redo();
ser.pAddUndoAction(action);


% Undo has to restore the values in configName as well as the current
% configuration since it's possible we are deleting the current configuration.

    function nRedo()
    % Set the current config to be configName.
    nser = distcomp.configserializer.pGetInstance();
    nser.pDelete(configName);
    end

    function nUndo()
    % Set the current config to be orgCurrent and re-create configName with
    % orgValues.
    nser = distcomp.configserializer.pGetInstance();
    if ~strcmp(configName, 'local')
        nser.pCreateNew(configName);
    end
    nser.Cache.current = orgCurrent;
    nser.pSave(configName, orgValues);
    end
end
