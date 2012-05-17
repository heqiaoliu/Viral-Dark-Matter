function attachListeners(this,varargin)
% Attach listeners to widgets owned by modeltype panel: model structure
% combo, model name and initial model list

% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2009/11/09 16:23:44 $

h = handle(this.jModelStructureCombo,'CallbackProperties');
L1 = handle.listener(h,'ActionPerformed', @(x,y)LocalStructureChanged(this));

h = handle(this.jModelNameEditLabel,'CallbackProperties');
L2 = handle.listener(h,'MouseClicked', @(x,y)LocalModelNameChange(this));

h = handle(this.jInitialModelButton,'CallbackProperties');
L4 = handle.listener(h,'ActionPerformed', {@LocalInitializeButtonPressed this});

h = nlutilspack.getMessengerInstance('OldSITBGUI'); %singleton
L5 = handle.listener(h,'identguichange',@(x,y)LocalModelChangedCallback(y,this));

this.Listeners = [L1,L2,L4,L5];

%--------------------------------------------------------------------------
function LocalStructureChanged(this)
% respond to change in model structure type

Ind = this.jModelStructureCombo.getSelectedIndex+1;
if (Ind==this.Data.StructureIndex) || (Ind<1)
    %no change
    return;
end

% disabling listener does not help because of asynchronous update of combo-box 
%en = this.Listeners(4).Enabled;
%set(this.Listeners(4),'Enabled','off'); 
this.Data.StructureIndex = Ind;
Type = this.getCurrentModelTypeID; %char(this.jMainPanel.getCurrentModelTypeID);

%x = this.Data.(Type).ExistingModels;
%selind = this.Data.(Type).SelectionIndex;
%x = nlutilspack.matlab2java(x,'vector');
%this.jMainPanel.setInitialModelComboList(x,selind-1);
this.jMainPanel.setModelName(java.lang.String(this.Data.(Type).ModelName));
%set(this.Listeners(4),'Enabled',en);

% update algorithm
nlgui = nlutilspack.getNLBBGUIInstance;
nlgui.EstimationPanel.updateAlgorithmProperties(this.getCurrentModel,nlgui);

% udpate current model display and reset checkboxes
currname = this.getCurrentModelPanel.LatestEstimModelName;
nlgui.setLatestEstimModelName(currname,Type);

if ~isempty(currname)
    if nlgui.EstimationPanel.jReiterateCheckBox.isSelected
        javaMethodEDT('setSelected',nlgui.EstimationPanel.jReiterateCheckBox,false);
    end

    if nlgui.EstimationPanel.jRandomizeCheckBox.isSelected
        javaMethodEDT('setSelected',nlgui.EstimationPanel.jRandomizeCheckBox,false);
    end
end

%--------------------------------------------------------------------------
function LocalModelNameChange(this)
% icon for model name change was pressed

import com.mathworks.mwswing.MJOptionPane;
gui = nlutilspack.getNLBBGUIInstance;
parent = gui.jGuiFrame;
WS = ctrlMsgUtils.SuspendWarnings('MATLAB:JavaEDTAutoDelegation');
Name = MJOptionPane.showInputDialog(...
    parent,'Specify a new name for model:','Model Name',...
    MJOptionPane.PLAIN_MESSAGE);
delete(WS)

Type = this.getCurrentModelTypeID; %char(this.jMainPanel.getCurrentModelTypeID);
[s,Name] = LocalValidateName(this,Type,Name);

if ~s
    return;
end

while isempty(Name) || ~isvarname(Name) || ismember(Name,nlutilspack.getAllModels(Type,true))
    % Specified name canot be accepted
    Name = MJOptionPane.showInputDialog(...
        parent,'Specify a unique and valid variable name:','Model Name',...
        MJOptionPane.WARNING_MESSAGE);
    [s,Name] = LocalValidateName(this,Type,Name);
    if ~s
        return
    end
end


this.jMainPanel.setModelName(java.lang.String(Name)); %thread-safe call
this.Data.(Type).ModelName = Name;

%--------------------------------------------------------------------------
function LocalInitializeButtonPressed(btn,ed,this)
% initial model combo box selection change callback
% -- a different initial model was selected by the user

%prepare input contents for the dialog's popup menu
this.InitModelDialog.show; 


%--------------------------------------------------------------------------
function LocalModelChangedCallback(ed,this)
% the list of models in the model board was changed (renamed, added or
% removed) or data object was changed

switch ed.propertyName
    case {'nlarxAdded','nlhwAdded'}
        this.handleModelAddedEvent(ed.Info.Model); %ed.Info is a struct 
    case 'nlarxRemoved'
        this.handleModelRemovedEvent('idnlarx',ed.Info); %ed.Info is a name only
    case 'nlhwRemoved'
        this.handleModelRemovedEvent('idnlhw',ed.Info);
    case 'nlarxRenamed'
        this.handleModelRenamedEvent('idnlarx',ed.OldValue,ed.NewValue);
    case 'nlhwRenamed'
        this.handleModelRenamedEvent('idnlhw',ed.OldValue,ed.NewValue);
    %case 'eDataChanged'
        %this.handleEstimDataChangedEvent(ed.newValue);
    %case 'vDataChanged'
        %disp('validation data changed')
    otherwise
        % do nothing 
end

%--------------------------------------------------------------------------
function [s,Name] = LocalValidateName(this,Type,Name)

s = true; % should name change be accepted and processed?  
if isa(Name,'double') && isempty(Name)
    %cancel button was pressed
    s = false;
    return
else
    % convert java.lang.String to MATLAB char
    Name = char(Name);
end

if ~isempty(Name) && strcmp(Name,this.Data.(Type).ModelName)
    % no name change
    s = false;
    return    
end
