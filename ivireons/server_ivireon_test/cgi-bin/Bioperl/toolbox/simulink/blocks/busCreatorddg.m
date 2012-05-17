function dlgStruct = busCreatorddg(source, block)

% Copyright 2003-2010 The MathWorks, Inc.

% Getting the BusStruct is expensive so get it now and 
% cache it in the block's UserData
if  ~isfield(block.UserData, 'flag') && ~block.isHierarchyReadonly
    ud.oldUserData = block.UserData;
    
    modelHandle = busCreatorddg_cb([], 'getModelHandleFromBlock',block);
    strictBusLvl = modelHandle.StrictBusMsg;
    ud.flag = slfeature('EditTimeBusPropagation') && ...
              (strcmp(strictBusLvl, 'ErrorLevel1') || ...
               strcmp(strictBusLvl, 'WarnOnBusTreatedAsVector') || ...
               strcmp(strictBusLvl, 'ErrorOnBusTreatedAsVector'));
    
    if ud.flag
        ud.signalHierarchy = block.SignalHierarchy;  
    else
        ud.busStruct       = block.BusStruct;
    end 
    block.UserData  = ud;
end

% If the dialog is undergoing a hard refresh, which is the case when the DTA is expanded/collapsed,
% The current status of the dialog widgets needs to be retained. We do so by querying the status
% of the open dialog.
hOpenDialog = source.getOpenDialogs;
if ~isempty(hOpenDialog);
    hOpenDialog = hOpenDialog{1};
end

% Top group is the block description
descText.Name                       = block.BlockDescription;
descText.Type                       = 'text';
descText.WordWrap                   = true;

descGroup.Name                      = block.BlockType;
descGroup.Type                      = 'group';
descGroup.Items                     = {descText};
descGroup.RowSpan                   = [1 1];
descGroup.ColSpan                   = [1 1];

% Bottom group is the block parameters
inheritCombo.Type                   = 'combobox';
inheritCombo.Entries                = {'Inherit bus signal names from input ports',...
                                       'Require input signal names to match signals below'};
inheritCombo.RowSpan                = [1 1];
inheritCombo.ColSpan                = [1 1];
inheritCombo.Tag                    = 'inheritCombo';
inheritCombo.MatlabMethod           = 'busCreatorddg_cb';
inheritCombo.MatlabArgs             = {'%dialog', 'doInherit'};
if ~isempty(hOpenDialog)
    inheritCombo.Value              = hOpenDialog.getWidgetValue(inheritCombo.Tag); 
end

numIn = busCreatorddg_cb([], 'getNumIn', source.state.Inputs);
numInEdit.Name                      = 'Number of inputs:';
numInEdit.Type                      = 'edit';
numInEdit.RowSpan                   = [2 2];
numInEdit.ColSpan                   = [1 1];
numInEdit.Value                     = numIn;
numInEdit.Tag                       = 'numInEdit';
numInEdit.MatlabMethod              = 'busCreatorddg_cb';
numInEdit.MatlabArgs                = {'%dialog', 'doInputs', source.state.Inputs};

[items handles] = busCreatorddg_cb([], 'getTreeItems', block, source.state.Inputs);
signalsTree.Name                    = 'Signals in bus';
signalsTree.Type                    = 'tree';
signalsTree.Graphical               = true;
signalsTree.TreeItems               = items;
signalsTree.UserData                = handles;
signalsTree.RowSpan                 = [1 5];
signalsTree.ColSpan                 = [1 1];
signalsTree.Tag                     = 'signalsTree';
signalsTree.MatlabMethod            = 'busCreatorddg_cb';
signalsTree.MatlabArgs              = {'%dialog', 'doTreeSelection', '%tag'};
if ~isempty(hOpenDialog)
    signalsTree.Visible             = hOpenDialog.isVisible(signalsTree.Tag); 
end

entries = busCreatorddg_cb([], 'getListEntries', block, source.state.Inputs);
signalsList.Name                    = 'Signals in bus';
signalsList.Type                    = 'listbox';
signalsList.MultiSelect             = 0;
signalsList.Entries                 = entries;
signalsList.UserData                = entries;
signalsList.RowSpan                 = [1 5];
signalsList.ColSpan                 = [1 1];
signalsList.MinimumSize             = [200 200];
signalsList.Tag                     = 'signalsList';
signalsList.MatlabMethod            = 'busCreatorddg_cb';
signalsList.MatlabArgs              = {'%dialog', 'doListSelection', '%tag'};
if ~isempty(hOpenDialog)
    signalsList.Visible             = hOpenDialog.isVisible(signalsList.Tag);
end

findButton.Name                     = 'Find';
findButton.Type                     = 'pushbutton';
findButton.RowSpan                  = [1 1];
findButton.ColSpan                  = [2 2];
findButton.Enabled                  = 0;
findButton.Tag                      = 'findButton';
findButton.MatlabMethod             = 'busCreatorddg_cb';
findButton.MatlabArgs               = {'%dialog', 'doFind'};
if ~isempty(hOpenDialog)
    findButton.Visible              = hOpenDialog.isVisible(findButton.Tag);
    findButton.Enabled              = hOpenDialog.isEnabled(findButton.Tag);
end

upButton.Name                       = 'Up';
upButton.Type                       = 'pushbutton';
upButton.RowSpan                    = [2 2];
upButton.ColSpan                    = [2 2];
upButton.Tag                        = 'upButton';
upButton.MatlabMethod               = 'busCreatorddg_cb';
upButton.MatlabArgs                 = {'%dialog', 'doUp'};
if ~isempty(hOpenDialog)
    upButton.Visible                = hOpenDialog.isVisible(upButton.Tag);
    upButton.Enabled                = hOpenDialog.isEnabled(upButton.Tag);
end

downButton.Name                     = 'Down';
downButton.Type                     = 'pushbutton';
downButton.RowSpan                  = [3 3];
downButton.ColSpan                  = [2 2];
downButton.Tag                      = 'downButton';
downButton.MatlabMethod             = 'busCreatorddg_cb';
downButton.MatlabArgs               = {'%dialog', 'doDown'};
if ~isempty(hOpenDialog)
    downButton.Visible              = hOpenDialog.isVisible(downButton.Tag);
    downButton.Enabled              = hOpenDialog.isEnabled(downButton.Tag); 
end

refreshButton.Name                  = 'Refresh';
refreshButton.Type                  = 'pushbutton';
refreshButton.RowSpan               = [4 4];
refreshButton.ColSpan               = [2 2];
refreshButton.Tag                   = 'refreshButton';
refreshButton.MatlabMethod          = 'busCreatorddg_cb';
refreshButton.MatlabArgs            = {'%dialog', 'unhilite', true};
if ~isempty(hOpenDialog)
    refreshButton.Visible           = hOpenDialog.isVisible(refreshButton.Tag);
end

spacer.Name                         = 'Spacer';
spacer.Type                         = 'panel';
spacer.RowSpan                      = [5 5];
spacer.ColSpan                      = [2 2];
spacer.Tag                          = 'Spacer';

spacer.Name                         = 'Spacer';
spacer.Type                         = 'panel';
spacer.RowSpan                      = [5 5];
spacer.ColSpan                      = [2 2];
spacer.Tag                          = 'Spacer';

renameEdit.Name                     = 'Rename selected signal:';
renameEdit.Type                     = 'edit';
renameEdit.RowSpan                  = [6 6];
renameEdit.ColSpan                  = [1 1];
renameEdit.Enabled                  = 0;
renameEdit.Tag                      = 'renameEdit';
renameEdit.MatlabMethod             = 'busCreatorddg_cb';
renameEdit.MatlabArgs               = {'%dialog', 'doRename', source.state.Inputs};
if ~isempty(hOpenDialog)
    renameEdit.Enabled              = hOpenDialog.isEnabled(renameEdit.Tag);
    renameEdit.Value                = hOpenDialog.getWidgetValue(renameEdit.Tag);
end

signalPanel.Type                    = 'panel';
signalPanel.Items                   = {signalsTree, signalsList, findButton, refreshButton, upButton, downButton, spacer, renameEdit};
signalPanel.LayoutGrid              = [6 2];
signalPanel.RowStretch              = [0 0 0 0 1 0];
signalPanel.ColStretch              = [1 0];
signalPanel.RowSpan                 = [3 3];
signalPanel.ColSpan                 = [1 1];

paramName = 'OutDataTypeStr';
dataTypeItems.inheritRules = Simulink.DataTypePrmWidget.getInheritList('Auto');
dataTypeItems.supportsBusType = true;
dataTypeItems.udtIndex = find(strcmp(paramName, source.getDialogParams), 1) - 1;
dataTypeGroup = Simulink.DataTypePrmWidget.getDataTypeWidget(source, ...
                                                  paramName, ...
                                                  xlate('Output data type:'), ...
                                                  paramName, ...
                                                  block.OutDataTypeStr, ...
                                                  dataTypeItems, ...
                                                  false);
dataTypeGroup.RowSpan = [1 1];
dataTypeGroup.ColSpan = [1 2];

outputCheck.Name                    = 'Output as nonvirtual bus';
outputCheck.Type                    = 'checkbox';
outputCheck.RowSpan                 = [2 2];
outputCheck.ColSpan                 = [1 2];
outputCheck.ObjectProperty          = 'NonVirtualBus';
outputCheck.Tag                     = outputCheck.ObjectProperty;
if ~isempty(hOpenDialog)
    outputCheck.Visible              = hOpenDialog.isVisible(outputCheck.Tag);
end

objectPanel.Type                    = 'panel';
objectPanel.Items                   = {dataTypeGroup, outputCheck};
objectPanel.LayoutGrid              = [2 2];
objectPanel.ColStretch              = [1 0];
objectPanel.RowSpan                 = [4 4];
objectPanel.ColSpan                 = [1 1];

% Invisible widgets mapping to object properties
inputsInvisible.Name                = 'Inputs';
inputsInvisible.Type                = 'edit';
inputsInvisible.Value               = source.state.Inputs;
inputsInvisible.Visible             = 0;
inputsInvisible.RowSpan             = [5 5];
inputsInvisible.ColSpan             = [1 2];
inputsInvisible.ObjectProperty      = 'Inputs';
inputsInvisible.Tag                 = inputsInvisible.ObjectProperty;
% ----------------------------------------------

paramGroup.Name                     = 'Parameters';
paramGroup.Type                     = 'group';
paramGroup.Items                    = {inheritCombo, numInEdit, signalPanel, objectPanel, inputsInvisible};
paramGroup.LayoutGrid               = [5 1];
paramGroup.RowStretch               = [0 0 1 0 0];
paramGroup.RowSpan                  = [2 2];
paramGroup.ColSpan                  = [1 1];
paramGroup.Source                   = block;

%-----------------------------------------------------------------------
% Assemble main dialog struct
%-----------------------------------------------------------------------
isLibraryLink = ~strcmp(get_param(bdroot(block.Handle),'Lock'), 'on') && ...
                ~strcmp(get_param(block.Handle, 'LinkStatus'), 'none');
title   = ['Block Parameters: ' strrep(block.Name, sprintf('\n'), ' ')];
disable = block.isHierarchySimulating || isLibraryLink;
dlgStruct.DialogTitle               = title;
dlgStruct.DialogTag                 = 'BusCreator';
dlgStruct.Items                     = {descGroup, paramGroup};
dlgStruct.LayoutGrid                = [2 1];
dlgStruct.RowStretch                = [0 1];
dlgStruct.DisableDialog             = disable;
dlgStruct.DefaultOk                 = false;
dlgStruct.OpenCallback              = @initialize;
dlgStruct.CloseCallback             = 'busCreatorddg_cb';
dlgStruct.CloseArgs                 = {'%dialog', 'doClose'};
dlgStruct.HelpMethod                = 'slhelp';
dlgStruct.HelpArgs                  = {block.Handle};
% Required for simulink/block sync ----
dlgStruct.PreApplyCallback          = 'busCreatorddg_cb';
dlgStruct.PreApplyArgs              = {'%dialog', 'doPreApply'};
% Required for deregistration ---------
dlgStruct.CloseMethod               = 'closeCallback';
dlgStruct.CloseMethodArgs           = {'%dialog'};
dlgStruct.CloseMethodArgsDT         = {'handle'};


% Initialization routine called on dialog open
function initialize(dlg)

if (~isnan(str2double(dlg.getSource.state.Inputs)))
    % Inherit bus signal names...
    dlg.setWidgetValue('inheritCombo', 0);
else
    % Require input signal names match...
    dlg.setWidgetValue('inheritCombo', 1);
end

dlg.apply;

busCreatorddg_cb(dlg, 'doInherit');

% LocalWords:  cb nonvirtual deregistration DTA
