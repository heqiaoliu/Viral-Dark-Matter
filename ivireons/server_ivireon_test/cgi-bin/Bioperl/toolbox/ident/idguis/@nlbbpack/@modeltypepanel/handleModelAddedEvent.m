function handleModelAddedEvent(this,model)
% handle the event of a new idnlarx/idnlhw model being added to the main
% GUI's model board.

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/31 06:12:34 $

messenger = nlutilspack.getMessengerInstance('OldSITBGUI'); %singleton

Type = class(model);
visibleType = this.getCurrentModelTypeID; %char(this.jMainPanel.getCurrentModelTypeID);
visibleTypeModified = strcmpi(Type,visibleType);
[ny,nu] = size(model);

ze = messenger.getCurrentEstimationData;
if ~isequal(size(ze,'ny'),ny) || ~isequal(size(ze,'nu'),nu)
    % incompatible model is not invisible to nlgui
    return;
end

%{
hasSameIONames = isequal(messenger.getInputNames,model.uname) && ...
     isequal(messenger.getOutputNames,model.yname);
%}

% cache selected initial model
%selmod = this.Data.(Type).ExistingModels{this.Data.(Type).SelectionIndex};

%Add model name to the combo
%strict = false; % do not care for mismatch in I/O names
%this.Data.(Type).ExistingModels = ['<none>',nlutilspack.getAllCompatibleModels(Type,true,strict)];
%selind = strmatch(selmod,this.Data.(Type).ExistingModels,'exact');

% update current model name if it clashes with new object's name
if strcmp(this.Data.(Type).ModelName,model.Name)
    newName = nlutilspack.generateUniqueModelName(Type,model.Name);
    this.Data.(Type).ModelName = newName;
    if visibleTypeModified
        this.jMainPanel.setModelName(newName);
    end
end

%{
if visibleTypeModified
    this.Data.(Type).SelectionIndex = 1; %to prevent selection changed callback from firing
    %this.jMainPanel.setInitialModelComboList(nlutilspack.matlab2java(this.Data.(Type).ExistingModels,'vector'));

    this.Data.(Type).SelectionIndex = selind;
    %awtinvoke(this.jInitialModelCombo,'setSelectedItem(Ljava.lang.Object;)',java.lang.String(selmod));
    javaMethodEDT('setSelectedIndex',this.jInitialModelCombo,this.Data.(Type).SelectionIndex-1); 
else
    this.Data.(Type).SelectionIndex = selind;
end
%}