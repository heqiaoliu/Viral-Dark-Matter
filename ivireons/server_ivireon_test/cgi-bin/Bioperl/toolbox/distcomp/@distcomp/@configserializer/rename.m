function rename(configName, newName)
; %#ok Undocumented
%Static method that renames the configuration to newName.
%   Throws an error if configName doesn't exist or newName is already in use.

%   Copyright 2007 The MathWorks, Inc.
    
ser = distcomp.configserializer.pGetInstance();
% This will throw an error if configName doesn't exist or is invalid.
ser.pGetID(configName);
% Get the current config for use in nUndo.
orgCurrent = ser.Cache.current;

% Verify that newName is a non-empty string.
if isempty(newName) || ~(ischar(newName) && length(newName) == size(newName, 2))
    error('distcomp:configuration:InvalidName', ...
          ['Cannot rename the configuration ''%s'' because the new name \n', ...
           'for the configuration is not a non-empty string.'], configName);
end

% Verify that newName doesn't exist:
allNames = {ser.Cache.configurations.Name};
if any(strcmp(allNames, newName))
    error('distcomp:configuration:NameInUse', ...
          ['Cannot rename the configuration ''%s'' to ''%s''\n', ...
          'because the configuration name ''%s'' is already in use.'],  ...
          configName, newName, newName);
end

currAction = com.mathworks.toolbox.distcomp.configurations.ConfigUndoAction.RENAME;
action = struct('redo', @nRedo, ...
                'undo', @nUndo, ...
                'action', currAction, ...
                'config', configName);
action.redo();
ser.pAddUndoAction(action);

    function nRedo() 
    % Rename configName to newName.
    nser = distcomp.configserializer.pGetInstance();
    % Perform the name change.
    nID = nser.pGetID(configName);
    nser.Cache.configurations(nID).Name = newName;
    if strcmp(configName, nser.Cache.current)
        % Also need to rename the current configuration.
        nser.Cache.current = newName;
    end
    % The user might have renamed the local configuration, but we handle
    % this when we flush the cache.
    nser.pFlushCache();
    end

    function nUndo() 
    % Rename newName to configName, and restore the original current 
    % configuration.
    nser = distcomp.configserializer.pGetInstance();
    % If configName was 'local', we re-created local when we renamed 
    % configName to newName.  This implies we must first delete local, then
    % reverse the rename.
    if strcmp(configName, 'local')
        localID = nser.pGetID('local');
        nser.Cache.configurations(localID) = [];
    end
    nID = nser.pGetID(newName);
    nser.Cache.configurations(nID).Name = configName;
    nser.Cache.current = orgCurrent;
    % The user might have renamed the local configuration, but we handle 
    % that when we flush the cache.
    nser.pFlushCache();
    end
end
