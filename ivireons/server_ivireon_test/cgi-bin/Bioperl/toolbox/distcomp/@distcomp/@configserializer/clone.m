function newName = clone(configName, proposedName)
; %#ok Undocumented
%Static method that copies all the data associated with configName into data
%associated with newName.

%   Copyright 2007 The MathWorks, Inc.
    
ser = distcomp.configserializer.pGetInstance();
% pGetID throws an error if configName is invalid.
% We obtain the new name and the values of the original configuration so that
% the nested functions can use them.
allValues = ser.Cache.configurations(ser.pGetID(configName)).Values;
newName = ser.pGetUnusedName(proposedName);

currAction = com.mathworks.toolbox.distcomp.configurations.ConfigUndoAction.CLONE;
action = struct('redo', @nRedo, ...
                'undo', @nUndo, ...
                'action', currAction, ...
                'config', configName);
action.redo();
ser.pAddUndoAction(action);

    function nRedo()
    % Performs the cloning of configName into newName
    nser = distcomp.configserializer.pGetInstance();    
    % Append the new configuration to the Cache:
    nser.Cache.configurations(end + 1).Name = newName;
    nser.Cache.configurations(end).Values = allValues;
    nser.pFlushCache();

    end
    function nUndo()
    % Deletes newName
    nser = distcomp.configserializer.pGetInstance();    
    nser.pDelete(newName);
    end
end
