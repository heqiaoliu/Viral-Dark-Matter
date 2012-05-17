function newName = createNew(proposedName, exactName)
; %#ok Undocumented
%Static method that creates a new configuration.
%   If exactName is provided and is available, create a configuration with that 
%   name, otherwise create a configuration using proposedName as the prefix.

%   Copyright 2007 The MathWorks, Inc.
    
ser = distcomp.configserializer.pGetInstance();
% Obtain the new name so that nRedo and nUndo both have access to it.
if nargin > 1
    if ~ismember(exactName, {ser.Cache.configurations.Name})
        newName = exactName;
    else
        newName = ser.pGetUnusedName(proposedName);
    end
else
    newName = ser.pGetUnusedName(proposedName);
end

currAction = com.mathworks.toolbox.distcomp.configurations.ConfigUndoAction.CREATE_NEW;
action = struct('redo', @nRedo,  ...
                'undo', @nUndo, ...
                'action', currAction, ...
                'config', newName);
action.redo();
ser.pAddUndoAction(action);

    function nRedo() 
    % Creates the empty configuration newName.
    nser = distcomp.configserializer.pGetInstance();
    nser.pCreateNew(newName);
    end

    function nUndo() 
    % Delete the configuration newName.
    nser = distcomp.configserializer.pGetInstance();    
    nser.pDelete(newName);
    end

end
