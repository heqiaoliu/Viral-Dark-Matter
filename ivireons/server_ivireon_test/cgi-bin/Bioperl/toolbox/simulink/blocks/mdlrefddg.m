function dlgStruct = mdlrefddg(source, h)

% Copyright 2008-2010 The MathWorks, Inc.

% Bottom group is the block parameters
paramGrp = i_GetParamGroup(source, h);

% Top group is the block description
descGrp = i_GetDescGroup(source, h);

%-----------------------------------------------------------------------
% Assemble main dialog struct
%-----------------------------------------------------------------------
dlgStruct.DialogTitle   = ['Block Parameters: ' strrep(h.Name, sprintf('\n'), ' ')];
dlgStruct.DialogTag     = 'ModelReference';
dlgStruct.Items         = {descGrp, paramGrp};
dlgStruct.LayoutGrid    = [2 1];
dlgStruct.RowStretch    = [0 1];

% For Block Help
dlgStruct.HelpMethod    = 'slhelp';
dlgStruct.HelpArgs      = {h.Handle};

% Required for simulink/block sync ----
dlgStruct.PreApplyCallback  = 'mdlrefddg_cb';
dlgStruct.PreApplyArgs      = {'doPreApply', '%dialog'};
dlgStruct.CloseCallback     = 'mdlrefddg_cb';
dlgStruct.CloseArgs         = {'doClose', '%dialog'};

% Required for deregistration ---------
dlgStruct.CloseMethod       = 'closeCallback';
dlgStruct.CloseMethodArgs   = {'%dialog'};
dlgStruct.CloseMethodArgsDT = {'handle'};

% Enable dialog
[~, isLocked] = source.isLibraryBlock(h);
if isLocked
  dlgStruct.DisableDialog = 1;
else
  dlgStruct.DisableDialog = 0;
end

%===============================================================================
function expandedPanel = i_GetVariantsPanels(source, h)

%% Table of Variants
if isempty(source.UserData)
    
    % Is variants enabled
    myData.Variant = strcmp(h.Variant, 'on');
    
    % Setup table data
    variants  = h.Variants;
    rows = length(variants);
    tableData = cell(rows, 6);
    if ~isempty(variants)
        for i = 1:length(variants)
            elem = variants(i);
            objName = elem.Name;
            tableData{i, 1} = objName;
            wid.Type      = 'edit';
            try
                wid.Value = evalin('base', [objName, '.Condition']);
            catch %#ok
                wid.Value = DAStudio.message('Simulink:dialog:NoVariantObject');
            end
            wid.Enabled   = 0;
%            wid.Alignment = 6; % center right

            tableData{i, 2} = wid;
            tableData{i, 3} = elem.ModelName;
            % update parameter argument names as they may have changed
            try
                paramArgNames = slInternal('getModelParameterArgumentNames', h.handle, elem.ModelName);
            catch %#ok
                paramArgNames = elem.ParameterArgumentNames;
            end
            
            tableData{i, 4} = paramArgNames;
            tableData{i, 5} = elem.ParameterArgumentValues;
            tableData{i, 6} = elem.SimulationMode;
        end
    end
    myData.TableData = tableData;
    
    % Setup entries and override variant
    if isempty(tableData)
        myData.Entries = {};
    else
        entries = tableData(:, 1);
        entries(strcmp(entries, '')) = [];
        myData.Entries = entries;
    end
    myData.OverrideVariant = h.OverrideUsingVariant;
    
    % Setup table selection
    idx = find(strcmp(tableData(:, 3), h.ModelNameDialog));
    if isempty(idx)
      idx = 1; % Default to first row
    else
      idx = idx(1); % In case of duplicates
    end
    myData.SelectedRow = idx - 1; % 0 based
    
    % Setup single variant display information
    if (size(tableData, 1) > 0)
        myData.Enabled       = 1;
        One.ModelName     = tableData{idx, 3};
        One.ParamArgNames = tableData{idx, 4};
        One.ParamArgVals  = tableData{idx, 5};
        One.SimMode       = tableData{idx, 6};
    else
        myData.Enabled       = 0;
        One.ModelName     = '';
        One.ParamArgNames = '';
        One.ParamArgVals  = '';
        One.SimMode       = '';
    end
        
    source.UserData = myData;
    
else
    % Update table
    myData    = source.UserData;
    tableData = myData.TableData;
    rows      = size(tableData, 1);

    % Update conditions field
    for i = 1:rows
        objName = tableData{i, 1};
        wid     = tableData{i, 2};
        try
            wid.Value = evalin('base', [objName, '.Condition']);
        catch %#ok
            wid.Value = DAStudio.message('Simulink:dialog:NoVariantObject');
        end
        wid.Enabled   = 0;
        tableData{i, 2} = wid;
    end
    
    % Data struct for initial population of one panel
    % Setup single variant display information
    if (size(tableData, 1) > 0)
        myData.Enabled    = 1;
        oneRow = myData.SelectedRow + 1;
        One.ModelName     = tableData{oneRow, 3};
        One.ParamArgNames = tableData{oneRow, 4};
        One.ParamArgVals  = tableData{oneRow, 5};
        One.SimMode       = tableData{oneRow, 6};
    else
        myData.Enabled    = 0;
        One.ModelName     = '';
        One.ParamArgNames = '';
        One.ParamArgVals  = '';
        One.SimMode       = '';
    end
    
    % Update combobox
    entries = tableData(:, 1);
    entries(strcmp(entries, '')) = [];
    myData.Entries = entries;
    source.UserData = myData;
end

%% Add button
pAdd.Name            = '';
pAdd.Type            = 'pushbutton';
pAdd.RowSpan         = [1 1];
pAdd.ColSpan         = [1 1];
pAdd.Enabled         = ~h.isLinked;
pAdd.FilePath        = fullfile(matlabroot,'toolbox/simulink/blocks/add.png'); 
pAdd.ToolTip         = DAStudio.message('Simulink:dialog:ModelRefAddTip');
pAdd.Tag             = 'AddButton';
pAdd.MatlabMethod    = 'mdlrefddg_cb';
pAdd.MatlabArgs      = {'doAdd', '%dialog'};

%% Delete button
pDelete.Name         = '';
pDelete.Type         = 'pushbutton';
pDelete.RowSpan      = [2 2];
pDelete.ColSpan      = [1 1];
pDelete.Enabled      = ~h.isLinked;
pDelete.FilePath     = fullfile(matlabroot,'toolbox/simulink/blocks/delete.png'); 
pDelete.ToolTip      = DAStudio.message('Simulink:dialog:ModelRefDeleteTip');
pDelete.Tag          = 'DeleteButton';
pDelete.MatlabMethod = 'mdlrefddg_cb';
pDelete.MatlabArgs   = {'doDelete', '%dialog'};

%% Edit variants object button
pEdit.Name           = '';
pEdit.Type           = 'pushbutton';
pEdit.RowSpan        = [3 3];
pEdit.ColSpan        = [1 1];
pEdit.Enabled        = 1;
pEdit.FilePath       = fullfile(matlabroot,'toolbox/shared/simulink/resources/EditVariantObject.png');
pEdit.ToolTip        = DAStudio.message('Simulink:dialog:SubsystemEditVariantObjectTip');
pEdit.Tag            = 'EditButton';
pEdit.MatlabMethod   = 'mdlrefddg_cb';
pEdit.MatlabArgs     = {'doEdit', '%dialog'};

%% Move Up button
pUp.Name             = '';
pUp.Type             = 'pushbutton';
pUp.RowSpan          = [4 4];
pUp.ColSpan          = [1 1];
pUp.FilePath         = fullfile(matlabroot,'toolbox/simulink/blocks/up.png'); 
pUp.ToolTip          = DAStudio.message('Simulink:dialog:ModelRefUpTip');
pUp.Tag              = 'UpButton';
pUp.Enabled          = ((myData.SelectedRow + 1) > 1) && ...
    ~h.isLinked;
pUp.MatlabMethod     = 'mdlrefddg_cb';
pUp.MatlabArgs       = {'doUp', '%dialog'};

%% Move Down button
pDown.Name           = '';
pDown.Type           = 'pushbutton';
pDown.RowSpan        = [5 5];
pDown.ColSpan        = [1 1];
pDown.FilePath       = fullfile(matlabroot,'toolbox/simulink/blocks/down.png'); 
pDown.ToolTip        = DAStudio.message('Simulink:dialog:ModelRefDownTip');
pDown.Tag            = 'DownButton';
pDown.Enabled        = ((myData.SelectedRow + 1) < size(tableData, 1)) && ...
    ~h.isLinked;
pDown.MatlabMethod   = 'mdlrefddg_cb';
pDown.MatlabArgs     = {'doDown', '%dialog'};

spacer1.Name         = '';
spacer1.Type         = 'text';
spacer1.RowSpan      = [6 6];
spacer1.ColSpan      = [1 1];

panel1.Type          = 'panel';
panel1.Items         = {pAdd, pDelete, pEdit, pUp, pDown, spacer1};
panel1.LayoutGrid    = [6 1];
panel1.RowStretch    = [0 0 0 0 0 1];
panel1.RowSpan       = [1 1];
panel1.ColSpan       = [1 1];

pTable.Name          = '';
pTable.Type          = 'table';
pTable.Size          = [rows 2];
pTable.Data          = tableData(:, 1:2);
pTable.Grid          = 1;
pTable.ColHeader     = {DAStudio.message('Simulink:dialog:VarTableColumn1'), ...
                        DAStudio.message('Simulink:dialog:VarTableColumn2')};
pTable.HeaderVisibility     = [0 1];
pTable.ColumnCharacterWidth = [10 10];
pTable.RowSpan       = [1 1];
pTable.ColSpan       = [2 2];
pTable.Enabled       = 1;
pTable.Editable      = 1;
pTable.LastColumnStretchable= 1;
pTable.MinimumSize   = [250 50];
pTable.Tag           = 'TableVariants';
pTable.CurrentItemChangedCallback = @i_TableSelectionChanged; 
pTable.ValueChangedCallback       = @i_TableValueChanged;
pTable.SelectedRow   = myData.SelectedRow;

tableGrp.Name        = DAStudio.message('Simulink:dialog:ModelRefVariantChoices');
tableGrp.Type        = 'group';
tableGrp.LayoutGrid  = [1 2];
tableGrp.ColStretch  = [0 1];
tableGrp.ColSpan     = [1 1];
tableGrp.RowSpan     = [1 1];
tableGrp.Items       = {panel1, pTable};

%% Get One Panel
onePanel = i_GetOnePanel(h, myData, One);

%% Create table pane
tablePanel.Name       = '';
tablePanel.Type       = 'panel';
tablePanel.LayoutGrid = [1 2];
tablePanel.ColStretch = [1 1];
tablePanel.ColSpan    = [1 1];
tablePanel.RowSpan    = [1 1];
tablePanel.Items      = {tableGrp, onePanel};


%% Active variant
idx = find(strcmp(myData.Entries, myData.OverrideVariant));
if isempty(idx)
    idx = 0;
else
    idx = idx(1); %in case multiple same named variant
    idx = idx - 1; %0 based
end

%  --------- variant override ----------
%  |
%  |  [x] Override variant conditions and use following
%  |  Variant: NAME-pulldown
% 
%  set_param(blk,'OverrideUsingVariant','')
%  set_param(blk,'OverrideUsingVariant','name')

pOverrideCheckbox.Name         = DAStudio.message('Simulink:dialog:ModelRefOverrideVariant');
pOverrideCheckbox.Type         = 'checkbox';
pOverrideCheckbox.Tag          = 'OverrideVariantCheckbox';
pOverrideCheckbox.Value        = ~isempty(myData.OverrideVariant);
pOverrideCheckbox.ToolTip      = DAStudio.message('Simulink:dialog:ModelRefOverrideVariantTip');
pOverrideCheckbox.MatlabMethod = 'mdlrefddg_cb';
pOverrideCheckbox.MatlabArgs   = {'doOverrideCheckbox', '%dialog'};

pOverride.Name          = DAStudio.message('Simulink:dialog:ModelRefOverrideVariantCombo');
pOverride.Type          = 'combobox';
pOverride.Tag           = 'OverrideVariantCombo';
pOverride.Entries       = myData.Entries;    
pOverride.Value         = idx;
pOverride.Enabled       = ~isempty(myData.OverrideVariant);
pOverride.ToolTip       = DAStudio.message('Simulink:dialog:ModelRefOverrideVariantTip');
pOverride.MatlabMethod  = 'mdlrefddg_cb';
pOverride.MatlabArgs    = {'doOverride', '%dialog'};

pOverrideGrp.Name       = '';
pOverrideGrp.Type       = 'panel';
pOverrideGrp.LayoutGrid = [2 1];
pOverrideGrp.Items      = {pOverrideCheckbox, pOverride};
pOverrideGrp.ColSpan    = [1 1];
pOverrideGrp.RowSpan    = [1 1];

%% Code generation check box
pCode                 = i_GetProperty(source, h, 'GeneratePreprocessorConditionals');
pCode.Name            = DAStudio.message('Simulink:dialog:ModelRefGenPreConditionals');
pCode.Enabled         = isempty(myData.OverrideVariant) && mdlrefddg_cb('IsGenerateCodeEnabled', h.Handle);
pCode.ToolTip         = DAStudio.message('Simulink:dialog:ModelRefGenPreConditionalsTip');

pCodeGrp.Name         = DAStudio.message('Simulink:dialog:ModelRefCodeGeneration');
pCodeGrp.Type         = 'group';
pCodeGrp.LayoutGrid   = [1 1];
pCodeGrp.Items        = {pCode};
pCodeGrp.ColSpan      = [2 2];
pCodeGrp.RowSpan      = [1 1];

%% Get button panel
varPanel = i_GetButtonPanelVariant(source, h);

%% Create bottom panel
botPanel.Name       = '';
botPanel.Type       = 'panel';
botPanel.LayoutGrid = [2 2];
botPanel.ColSpan    = [1 1];
botPanel.RowSpan    = [2 2];
botPanel.Items      = {pOverrideGrp, pCodeGrp, varPanel};

expandedPanel.Name       = '';
expandedPanel.Type       = 'panel';
expandedPanel.LayoutGrid = [2 1];
expandedPanel.Items      = {tablePanel, botPanel};

%===============================================================================
function mainPanel = i_GetMainPanel(source, h)

%% Model Name and Open Model button
pModelName                = i_GetProperty(source, h, 'ModelNameDialog');
pModelName.NameLocation   = 2;
pModelName.RowSpan        = [1 1];
pModelName.ColSpan        = [1 1];
pModelName.Enabled        = ~source.isHierarchySimulating && ~h.isLinked;
% required for synchronization --------
% pModelName.MatlabMethod   = 'slDialogUtil'; %
% pModelName.MatlabArgs     = {source,'sync','%dialog','edit','%tag'};%

pModelBrowse.Name           = DAStudio.message('Simulink:dialog:ModelRefBrowse');
pModelBrowse.Alignment      = 10;
pModelBrowse.Type           = 'pushbutton';
pModelBrowse.RowSpan        = [1 1];
pModelBrowse.ColSpan        = [2 2];
pModelBrowse.Enabled        = ~source.isHierarchySimulating && ~h.isLinked;
pModelBrowse.Tag            = 'ModelBrowse';
pModelBrowse.MatlabMethod   = 'mdlrefddg_cb';
pModelBrowse.MatlabArgs     = {'doBrowse', '%dialog', 'ModelNameDialog'};

protected = slprivate('isUsingProtectedModel', h.ModelNameDialog);

pModelOpen.Name           = DAStudio.message('Simulink:dialog:ModelRefOpen');
pModelOpen.Alignment      = 10;
pModelOpen.Type           = 'pushbutton';
pModelOpen.RowSpan        = [1 1];
pModelOpen.ColSpan        = [3 3];
pModelOpen.Enabled        = ~protected;
pModelOpen.Tag            = 'ModelOpen';
pModelOpen.MatlabMethod   = 'mdlrefddg_cb';
pModelOpen.MatlabArgs     = {'doOpen', '%dialog'};

% Put these 3 widgets together
rowIdx = 1;
pModelNamePanel.Name       = '';
pModelNamePanel.Type       = 'panel';
pModelNamePanel.LayoutGrid = [1 3];
pModelNamePanel.RowSpan    = [rowIdx, rowIdx];
pModelNamePanel.ColStretch = [1 0 0];
pModelNamePanel.Items      = {pModelName, pModelBrowse, pModelOpen};

%% Model Arguments
rowIdx = rowIdx + 1;
pModelArgs                = i_GetProperty(source, h, 'ParameterArgumentNames');
pModelArgs.NameLocation   = 2;
pModelArgs.RowSpan        = [rowIdx rowIdx];
pModelArgs.Enabled        = 0;
% required for synchronization --------
%pModelArgs.MatlabMethod   = 'slDialogUtil';
%pModelArgs.MatlabArgs     = {source,'sync','%dialog','edit','%tag'};

%% Model Argument Values
rowIdx = rowIdx + 1;
pModelArgVals             = i_GetProperty(source, h, 'ParameterArgumentValues');
pModelArgVals.NameLocation= 2;
pModelArgVals.RowSpan     = [rowIdx rowIdx];
pModelArgVals.Enabled     = ~source.isHierarchySimulating;
% required for synchronization --------
%pModelArgVals.MatlabMethod= 'slDialogUtil';
%pModelArgVals.MatlabArgs  = {source,'sync','%dialog','edit','%tag'};

%% Simulation Mode
rowIdx = rowIdx + 1;
pSimMode                  = i_GetProperty(source, h, 'SimulationMode');
pSimMode.RowSpan          = [rowIdx rowIdx];
pSimMode.Enabled          = ((~ source.isHierarchySimulating) && ...
                             (~ protected));
% required for synchronization --------
%pSimMode.MatlabMethod     = 'slDialogUtil';
%pSimMode.MatlabArgs       = {source,'sync','%dialog','edit','%tag'};

%% Spacer
rowIdx = rowIdx + 1;
spacer.Name    = '';
spacer.Type    = 'text';
spacer.RowSpan = [rowIdx rowIdx];

%% Main panel
paramPanel.Name         = 'Parameters';
paramPanel.Type         = 'group';
paramPanel.LayoutGrid   = [5 1];
paramPanel.RowStretch   = [0 0 0 0 1];
paramPanel.RowSpan      = [1 1];
paramPanel.ColSpan      = [1 1];
paramPanel.Items        = {pModelNamePanel, pModelArgs, pModelArgVals, pSimMode, spacer};

%% Get button panel
varPanel = i_GetButtonPanelMain(source, h);

mainPanel.Type = 'panel';
mainPanel.LayoutGrid = [2 1];
mainPanel.Items = {paramPanel, varPanel};

%==========================================================================
function varPanel = i_GetButtonPanelMain(source, h)

myData = source.UserData;
%% Add toggle button
if myData.Variant
    varButton.Name = DAStudio.message('Simulink:dialog:ModelRefDisableVariants');
else
    varButton.Name = DAStudio.message('Simulink:dialog:ModelRefEnableVariants');
end
varButton.Type           = 'pushbutton';
varButton.Enabled        = ~h.isLinked;
varButton.RowSpan        = [1 1];
varButton.ColSpan        = [1 1];
varButton.Tag            = 'MainVariant';
varButton.MatlabMethod   = 'mdlrefddg_cb';
varButton.MatlabArgs     = {'doVariant', '%dialog'};

spacer3.Name           = '';
spacer3.Type           = 'text';
spacer3.RowSpan        = [1 1];
spacer3.ColSpan        = [2 2];

varPanel.Name        = '';
varPanel.Type        = 'panel';
varPanel.LayoutGrid  = [1 2];
varPanel.RowSpan     = [2 2];
varPanel.ColSpan     = [1 1];

varPanel.Items       = {varButton, spacer3};
varPanel.ColStretch  = [0 1];

%==========================================================================
function varPanel = i_GetButtonPanelVariant(source, h)

myData = source.UserData;
%% Add toggle button
if myData.Variant
    varButton.Name = DAStudio.message('Simulink:dialog:ModelRefDisableVariants');
else
    varButton.Name = DAStudio.message('Simulink:dialog:ModelRefEnableVariants');
end
varButton.Type           = 'pushbutton';
varButton.Enabled        = ~h.isLinked;
varButton.RowSpan        = [1 1];
varButton.ColSpan        = [2 2];
varButton.Tag            = 'VariantVariant';
varButton.MatlabMethod   = 'mdlrefddg_cb';
varButton.MatlabArgs     = {'doVariant', '%dialog'};

spacer3.Name           = '';
spacer3.Type           = 'text';
spacer3.RowSpan        = [1 1];
spacer3.ColSpan        = [1 1];

varPanel.Name        = '';
varPanel.Type        = 'panel';
varPanel.LayoutGrid  = [1 2];
varPanel.RowSpan     = [2 2];
varPanel.ColSpan     = [1 2];
varPanel.Items       = {spacer3, varButton};
varPanel.ColStretch  = [1 0];

%==========================================================================
function onePanel = i_GetOnePanel(h, myData, One)
%% Model Name
pOneModel.Name         = h.IntrinsicDialogParameters.ModelNameDialog.Prompt;
pOneModel.Type         = 'edit';
pOneModel.NameLocation = 2;
pOneModel.RowSpan      = [1 1];
pOneModel.ColSpan      = [1 1];
pOneModel.MinimumSize  = [200 0];
pOneModel.Enabled      = myData.Enabled && ~h.isLinked;
pOneModel.Graphical    = 1;
pOneModel.Tag          = 'OneModelName';
pOneModel.Value        = One.ModelName;
pOneModel.MatlabMethod  = 'mdlrefddg_cb';
pOneModel.MatlabArgs    = {'doOneUpdate', '%dialog', pOneModel.Tag, 3};

pOneBrowse.Name          = DAStudio.message('Simulink:dialog:ModelRefBrowse');
pOneBrowse.Alignment     = 10;
pOneBrowse.Type          = 'pushbutton';
pOneBrowse.RowSpan       = [1 1];
pOneBrowse.ColSpan       = [2 2];
pOneBrowse.Enabled       = myData.Enabled && ~h.isLinked;
pOneBrowse.Tag           = 'OneModelBrowse';
pOneBrowse.MatlabMethod  = 'mdlrefddg_cb';
pOneBrowse.MatlabArgs    = {'doBrowse', '%dialog', 'OneModelName'};

protected = slprivate('isUsingProtectedModel', One.ModelName);

pOneOpen.Name          = DAStudio.message('Simulink:dialog:ModelRefOpen');
pOneOpen.Alignment     = 10;
pOneOpen.Type          = 'pushbutton';
pOneOpen.RowSpan       = [1 1];
pOneOpen.ColSpan       = [3 3];
pOneOpen.Enabled       = myData.Enabled && ~isempty(One.ModelName) && (~protected);
pOneOpen.Tag           = 'OneModelOpen';
pOneOpen.MatlabMethod  = 'mdlrefddg_cb';
pOneOpen.MatlabArgs    = {'doOneOpen', '%dialog'};

% Put these 3 widgets together
pOneNamePanel.Name       = '';
pOneNamePanel.Type       = 'panel';
pOneNamePanel.LayoutGrid = [1 3];
pOneNamePanel.RowSpan    = [1 1];
pOneNamePanel.ColStretch = [1 0 0];
pOneNamePanel.Items      = {pOneModel, pOneBrowse, pOneOpen};

%% Model Arguments
pOneArgs.Name          = h.IntrinsicDialogParameters.ParameterArgumentNames.Prompt;
pOneArgs.Type          = 'edit';
pOneArgs.NameLocation  = 2;
pOneArgs.RowSpan       = [2 2];
pOneArgs.Enabled       = 0;
pOneArgs.Graphical     = 1;
pOneArgs.Tag           = 'OneArgName';
pOneArgs.Value         = One.ParamArgNames;

%% Model Argument Values
pOneArgVals.Name       = h.IntrinsicDialogParameters.ParameterArgumentValues.Prompt;
pOneArgVals.Type       = 'edit';
pOneArgVals.NameLocation= 2;
pOneArgVals.RowSpan    = [3 3];
pOneArgVals.Enabled    = myData.Enabled;
pOneArgVals.Graphical  = 1;
pOneArgVals.Tag        = 'OneArgVal';
pOneArgVals.Value      = One.ParamArgVals;
pOneArgVals.MatlabMethod= 'mdlrefddg_cb';
pOneArgVals.MatlabArgs    = {'doOneUpdate', '%dialog', pOneArgVals.Tag, 5};

%% Simulation Mode
pOneMode.Name          = h.IntrinsicDialogParameters.SimulationMode.Prompt;
pOneMode.Type          = 'combobox';
pOneMode.Entries       = h.getPropAllowedValues('SimulationMode');
pOneMode.RowSpan       = [4 4];
pOneMode.Enabled       = ((myData.Enabled) && (~protected));
pOneMode.Graphical     = 1;
pOneMode.Tag           = 'OneSimMode';
pOneMode.Value         = One.SimMode;
pOneMode.MatlabMethod  = 'mdlrefddg_cb';
pOneMode.MatlabArgs    = {'doOneUpdate', '%dialog', pOneMode.Tag, 6};

%% Spacer
spacer2.Name           = '';
spacer2.Type           = 'text';
spacer2.RowSpan        = [5 5];

%% Arguments panel
onePanel.Name         = DAStudio.message('Simulink:dialog:ModelRefVariantDetails');
onePanel.Type         = 'group';
onePanel.LayoutGrid   = [5 1];
onePanel.RowStretch   = [0 0 0 0 1];
onePanel.RowSpan      = [1 1];
onePanel.ColSpan      = [2 2];
onePanel.Items        = {pOneNamePanel, pOneArgs, pOneArgVals, pOneMode, spacer2};

%===============================================================================
function property = i_GetProperty(source, h, propName)
% Get relevant property information for requested property

% The ObjectProperty and the Tag are mostly the same.
property.ObjectProperty = propName;
property.Tag            = propName;

% Extract the prompt string from the block itself.
property.Name           = h.IntrinsicDialogParameters.(propName).Prompt;

% Choose the proper dialog parameter type.
switch lower(h.IntrinsicDialogParameters.(propName).Type)
  case 'enum'
    property.Type         = 'combobox';
    property.Entries      = h.getPropAllowedValues(propName);
    property.MatlabMethod = 'handleComboSelectionEvent';
  case 'boolean'
    property.Type         = 'checkbox';
    property.MatlabMethod = 'handleCheckEvent';
  otherwise
    property.Type         = 'edit';        
    property.MatlabMethod = 'handleEditEvent';
end
property.MatlabArgs = {source, '%value', find(strcmp(source.paramsMap, propName))-1, '%dialog'};

%==========================================================================
function i_TableSelectionChanged(dialogH, row, ~)

source = dialogH.getSource;

enabled = (row >= 0); 
dialogH.setEnabled('OneModelName', enabled && ~source.getBlock.isLinked);
dialogH.setEnabled('OneModelOpen', enabled);
dialogH.setEnabled('OneArgVal',    enabled);
dialogH.setEnabled('OneSimMode',   enabled);

if ~enabled
    return;
end

% Select row
dialogH.selectTableRow('TableVariants', row);
myData = source.UserData;
data   = myData.TableData;

% Update buttons
dialogH.setEnabled('UpButton', ((row + 1) > 1) && ...
                               ~source.getBlock.isLinked);
dialogH.setEnabled('DownButton', ((row + 1) < size(data, 1)) && ...
                                 ~source.getBlock.isLinked);

% Update selection info
myData.SelectedRow   = row;
myData.Enabled       = enabled;

% Update time
mdlrefddg_cb('doUpdateFields', dialogH, data(row+1, :));

% Cache it back
source.UserData = myData;

%% ======================================================================
function paramGrp = i_GetParamGroup(source, h)

% Get the variants for the Model Reference block
expandedPanel = i_GetVariantsPanels(source, h);

% Get Main Panel
mainPanel = i_GetMainPanel(source, h);

% Construct the parameters tab
myData = source.UserData;
expandedPanel.Visible = myData.Variant;
mainPanel.Visible     = ~myData.Variant;

paramGrp.Type       = 'panel';
paramGrp.LayoutGrid = [1 1];
paramGrp.Items      = {expandedPanel, mainPanel};
paramGrp.RowSpan    = [2 2];
paramGrp.ColSpan    = [1 1];
paramGrp.Source     = h;





%% ======================================================================
function descGrp = i_GetDescGroup(source, h)

variantsEnabled = source.UserData.Variant;

text = h.BlockDescription;
cr   = sprintf('\n');
text = [text, cr, cr, DAStudio.Message('Simulink:dialog:ModelRefVisibilityDetail')];
text = [text, cr, cr, DAStudio.Message('Simulink:dialog:ModelRefVariantShortDetail')];
if(variantsEnabled)
    text = [text, '  ', DAStudio.Message('Simulink:dialog:ModelRefVariantLongDetail')];
end

descTxt.Name            = text;
descTxt.Type            = 'text';
descTxt.WordWrap        = true;
descTxt.RowSpan         = [1 1];
descTxt.ColSpan         = [1 1];
descTxt.Tag             = 'ModelReferenceBlockDescriptionText';

descGrp.Name            = h.BlockType;
descGrp.Type            = 'group';
descGrp.Items           = {descTxt};
descGrp.LayoutGrid      = [1 1];


%==========================================================================
function i_TableValueChanged(dialogH, row, col, newVal)

% Update table
source = dialogH.getSource;
myData = source.UserData;
data   = myData.TableData;
data{row+1, col+1} = newVal;
myData.TableData = data;
source.UserData = myData;

if (col == 0)
    % Name has changed, so update combobox choices
    dialogH.refresh;
end
