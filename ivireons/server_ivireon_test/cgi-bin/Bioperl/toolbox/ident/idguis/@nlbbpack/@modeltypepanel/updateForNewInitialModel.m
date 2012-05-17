function updateForNewInitialModel(this,Type,newModelName,algoUpdate)
%Update all GUI widgets to agree with the new Initial model
% Type: 'idnlarx' or 'idnlhw'.
% algoUpdate: update algorithm properties  (true) or not (false)
%
% This method finds the right model type and delgates the task of
% updating to panel class of the panel type (nlarxpanel or nlhwpanel).

% Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/31 06:12:42 $


ActivePanelObj = this.getPanelForType(Type);

if isempty(newModelName) 
    Model = ActivePanelObj.createDefaultModel;
else
    % find the model with name newModelName and use it to repopulate the
    % gui widgets
    allmodels = nlutilspack.getAllCompatibleModels(Type,false,false);
    Model = [];
    for k = 1:length(allmodels)
        if strcmp(allmodels{k}.Name,newModelName)
            Model = allmodels{k};
            break;
        end
    end
end

if isempty(Model)
    %disp(sprintf('Model %s was not found. No action taken.',newModelName));
    return;
end

ActivePanelObj.updateForNewInitialModel(Model);

nlgui = nlutilspack.getNLBBGUIInstance;

if ~strcmp(ActivePanelObj.LatestEstimModelName,newModelName)
    nlbbpack.sendModelChangedEvent(class(Model));
end

if algoUpdate
    % update algorithm properties
    nlgui.EstimationPanel.updateAlgorithmProperties(Model,nlgui);
end

% Update Estimation Panel Reiteration Options
% 1. If selected model is not same as current model, uncheck estimation
% panel's reiteration checkboxes.
% 2. If selected model matches current model, do nothing.
currname = ActivePanelObj.LatestEstimModelName;
if ~strcmp(currname,newModelName)
    if nlgui.EstimationPanel.jReiterateCheckBox.isSelected
        javaMethodEDT('setSelected',nlgui.EstimationPanel.jReiterateCheckBox,false);
    end
    
    if nlgui.EstimationPanel.jRandomizeCheckBox.isSelected
        javaMethodEDT('setSelected',nlgui.EstimationPanel.jRandomizeCheckBox,false);
    end
end
