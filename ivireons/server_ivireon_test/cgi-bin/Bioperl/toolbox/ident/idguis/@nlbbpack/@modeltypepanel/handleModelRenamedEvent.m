function handleModelRenamedEvent(this,Type,oldName,newName)
% handle the event of a model bein renamed in the main GUI.

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/31 06:12:37 $

visibleType = this.getCurrentModelTypeID; %char(this.jMainPanel.getCurrentModelTypeID);
visibleTypeModified = strcmpi(Type,visibleType);

%this.InitModelDialog.Data.(Type).ExistingModels{Loc} = newName;

if visibleTypeModified
    % update current model name if it clashes with newName
    if strcmp(this.Data.(Type).ModelName,newName)
        newName = nlutilspack.generateUniqueModelName(Type,newName);
        this.jMainPanel.setModelName(newName);
        this.Data.(Type).ModelName = newName;
    end
end

% if current model (model last estimated) is being renamed, update the
% LatestEstimModelName property in appropriate model panel
currname = this.getPanelForType(Type).LatestEstimModelName;
if strcmp(currname,oldName)
    nlgui = nlutilspack.getNLBBGUIInstance;
    nlgui.setLatestEstimModelName(newName,Type);
end
