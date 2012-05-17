function setCurrentName(configName)
; %#ok Undocumented
% A static method that sets the name of the current configurations.

%   Copyright 2007 The MathWorks, Inc.

% Verify that configName is a string.
if ~(ischar(configName) && length(configName) == size(configName, 2))
    error('distcomp:configuration:invalidName', ...
          'Configuration name must be a string.');
end
ser = distcomp.configserializer.pGetInstance();

% Verify that the specified configuration actually exists.
allNames = {ser.Cache.configurations.Name};
if ~any(strcmp(allNames, configName))
    error('distcomp:configuration:invalidConfiguration', ...
          ['Cannot set the default configuration to be ''%s'' because\n',...
           'there is no configuration with that name.'], configName);
end

orgCurrent = ser.Cache.current;

action = struct('redo', @nRedo, 'undo', @nUndo, ...
                'action', com.mathworks.toolbox.distcomp.configurations.ConfigUndoAction.SET_DEFAULT, ...
           'config', configName);
action.redo();
ser.pAddUndoAction(action);

    function nRedo()
    % Set the current config to be configName.
     nser = distcomp.configserializer.pGetInstance();
     nser.Cache.current = configName;
     nser.pFlushCache();
    end

    function nUndo()
    % Set the current config to be orgCurrent.
    nser = distcomp.configserializer.pGetInstance();
    nser.Cache.current = orgCurrent;
    nser.pFlushCache();
    end

end
