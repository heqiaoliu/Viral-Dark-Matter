function dlgStruct = dtf_ddg(source, h)
% DTF_DDG
%   DDG schema for Discrete Filter and Discrete Transfer Fcn block parameter 
%   dialog.
%

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $

% Top group is the block description
descTxt.Name     = h.BlockDescription;
descTxt.Type     = 'text';
descTxt.WordWrap = true;

if strcmpi(h.BlockType,'DiscreteFilter')
    descGrp.Name = 'Discrete Filter';
else
    descGrp.Name = 'Discrete Transfer Fcn';
end
descGrp.Type     = 'group';
descGrp.Items    = {descTxt};
descGrp.RowSpan  = [1 1];
descGrp.ColSpan  = [1 1];

% Reset the dialog layout, two columns for the prompt, three for the data.
layoutRow    = 0; % Row counter.
layoutPrompt = 1; % Number of grid columns for the prompt widgets, when separate.
layoutValue  = 4; % Number of grid columns for the value widgets, when separate.
layoutCols = layoutPrompt + layoutValue; % The grid width.

% Bottom group is the block parameters
layoutRow = layoutRow + 1;
[numeratorPrompt numeratorValue] = create_widget(source, h, ...
    'Numerator', layoutRow, layoutPrompt, layoutValue);

layoutRow = layoutRow + 1;
[denominatorPrompt denominatorValue] = create_widget(source, h, ...
    'Denominator', layoutRow, layoutPrompt, layoutValue);

layoutRow = layoutRow + 1;
[initialStatesPrompt initialStatesValue] = create_widget(source, h, ...
    'InitialStates', layoutRow, layoutPrompt, layoutValue);    

layoutRow = layoutRow + 1;
[tsPrompt tsValue] = create_widget(source, h, 'SampleTime', ...
                            layoutRow, layoutPrompt, layoutValue);
                                
layoutRow = layoutRow + 1;
a0EqualsOneValue = create_widget(source, h, 'a0EqualsOne', ...
                     layoutRow, layoutPrompt, layoutValue);
                                
layoutRow = layoutRow + 1;
spacer.Name    = '';
spacer.Type    = 'text';
spacer.RowSpan = [layoutRow layoutRow];
spacer.ColSpan = [1         layoutCols];

mainTab.Name       = 'Main';
mainTab.Items      = { ...
    ...% Prompts        Data
    numeratorPrompt     numeratorValue  ...
    denominatorPrompt   denominatorValue  ...
    initialStatesPrompt initialStatesValue  ...
    tsPrompt            tsValue  ...
                        a0EqualsOneValue ...
                        spacer };
                    
mainTab.LayoutGrid = [layoutRow layoutCols];
mainTab.ColStretch = [ones( 1, mainTab.LayoutGrid(2)-1) 0]; % Stretch all columns, but the last.
mainTab.RowStretch = [zeros(1, mainTab.LayoutGrid(1)-1) 1]; % Stretch only the last row.



% Data Type Attributes tab.
% Reset the dialog layout. Start the row counter over from zero.
layoutRow = 0;

% UDT String and DTA GUI Object Layout on dialog
% (Columns: Prompt, Combobox, DTA_Button, DesignMin, DesignMax)
% -------------------------------------------------------------
dtaPrmColIdx  = 1; % Prompt column index
dtaUDTColIdx  = 2; % Combobox column index
dtaBtnColIdx  = 3; % DTA button column index
desMinColIdx  = 4; % Design Min column index
desMaxColIdx  = 5; % Design Max column index
layoutCols    = desMaxColIdx;

% Floating point trump text
layoutRow = layoutRow + 1;
discStr = DAStudio.message('Simulink:dialog:FloatingPointTrumpRule');
discText.Type = 'text';
discText.Tag  = 'discText';
discText.Name = discStr;
discText.Mode = false;
discText.WordWrap = 1;
discText.RowSpan  = [layoutRow layoutRow];
discText.ColSpan  = [1         layoutCols];

% Data type widget column labels
layoutRow = layoutRow + 1;
dtColText.Type = 'text';
dtColText.Tag  = 'dtColText';
dtColText.Name = DAStudio.message('Simulink:dialog:DataTypeColumnLabel');
dtColText.Mode = false;
dtColText.RowSpan = [layoutRow    layoutRow];
dtColText.ColSpan = [dtaUDTColIdx dtaUDTColIdx];

dtaColText.Type = 'text';
dtaColText.Tag  = 'dtaColText';
dtaColText.Name = DAStudio.message('Simulink:dialog:AssistantColumnLabel');
dtaColText.Mode = false;
dtaColText.RowSpan = [layoutRow    layoutRow];
dtaColText.ColSpan = [dtaBtnColIdx dtaBtnColIdx];

minColText.Type = 'text';
minColText.Tag  = 'minColText';
minColText.Name = DAStudio.message('Simulink:dialog:MinimumColumnLabel');
minColText.Mode = false;
minColText.RowSpan = [layoutRow    layoutRow];
minColText.ColSpan = [desMinColIdx desMinColIdx];

maxColText.Type = 'text';
maxColText.Tag  = 'maxColText';
maxColText.Name = DAStudio.message('Simulink:dialog:MaximumColumnLabel');
maxColText.Mode = false;
maxColText.RowSpan = [layoutRow    layoutRow];
maxColText.ColSpan = [desMaxColIdx desMaxColIdx];


% Common Unified data type items
commonItems.scalingModes   = Simulink.DataTypePrmWidget.getScalingModeList('BPt');
commonItems.signModes      = Simulink.DataTypePrmWidget.getSignModeList('SignOnly');
commonItems.builtinTypes   = Simulink.DataTypePrmWidget.getBuiltinList('SignedInt');
commonItems.scalingValueTags = {};
commonItems.scalingMinTag      = {};
commonItems.scalingMaxTag      = {};
commonItems.lockScalingTag     = 'LockScale';

% state
dataTypeItems = commonItems;
dataTypeItems.inheritRules  = Simulink.DataTypePrmWidget.getInheritList('In');
dataTypeParamName = 'StateDataTypeStr';
stateUdtSpec.hDlgSource = source;
stateUdtSpec.dtName     = dataTypeParamName;
stateUdtSpec.dtPrompt   = DAStudio.message('Simulink:dialog:StatePrompt');
stateUdtSpec.dtTag      = dataTypeParamName;
stateUdtSpec.dtVal      = h.StateDataTypeStr;
stateUdtSpec.dtaItems   = dataTypeItems;
stateUdtSpec.customAsstName = false;

% Numerator coefficient
dataTypeItems = commonItems;
dataTypeItems.inheritRules  = Simulink.DataTypePrmWidget.getInheritList('IR');
dataTypeItems.scalingModes  = Simulink.DataTypePrmWidget.getScalingModeList('BPt_Best');
dataTypeItems.scalingValueTags = {'Numerator'};
dataTypeItems.scalingMinTag    = {'NumCoefMin'};
dataTypeItems.scalingMaxTag    = {'NumCoefMax'};
dataTypeParamName = 'NumCoefDataTypeStr';
numCoefUdtSpec.hDlgSource = source;
numCoefUdtSpec.dtName     = dataTypeParamName;
numCoefUdtSpec.dtPrompt   = DAStudio.message('Simulink:dialog:NumCoefPrompt');
numCoefUdtSpec.dtTag      = dataTypeParamName;
numCoefUdtSpec.dtVal      = h.NumCoefDataTypeStr;
numCoefUdtSpec.dtaItems   = dataTypeItems;
numCoefUdtSpec.customAsstName = false;

% Numerator product
dataTypeItems = commonItems;
dataTypeItems.inheritRules  = Simulink.DataTypePrmWidget.getInheritList('IR_In');
dataTypeParamName = 'NumProductDataTypeStr';
numProdUdtSpec.hDlgSource = source;
numProdUdtSpec.dtName     = dataTypeParamName;
numProdUdtSpec.dtPrompt   = DAStudio.message('Simulink:dialog:NumProdPrompt');
numProdUdtSpec.dtTag      = dataTypeParamName;
numProdUdtSpec.dtVal      = h.NumProductDataTypeStr;
numProdUdtSpec.dtaItems   = dataTypeItems;
numProdUdtSpec.customAsstName = false;

% Numerator accumulator
numAccumDataTypeItems = commonItems;
numAccumDataTypeItems.inheritRules  = Simulink.DataTypePrmWidget.getInheritList('IR_In_Prod');
dataTypeParamName = 'NumAccumDataTypeStr';
numAccumUdtSpec.hDlgSource = source;
numAccumUdtSpec.dtName     = dataTypeParamName;
numAccumUdtSpec.dtPrompt   = DAStudio.message('Simulink:dialog:NumAccumPrompt');
numAccumUdtSpec.dtTag      = dataTypeParamName;
numAccumUdtSpec.dtVal      = h.NumAccumDataTypeStr;
numAccumUdtSpec.dtaItems   = numAccumDataTypeItems;
numAccumUdtSpec.customAsstName = false;

% Denominator coefficient
dataTypeItems = commonItems;
dataTypeItems.inheritRules  = Simulink.DataTypePrmWidget.getInheritList('IR');
dataTypeItems.scalingModes  = Simulink.DataTypePrmWidget.getScalingModeList('BPt_Best');
dataTypeItems.scalingValueTags = {'Denominator'};
dataTypeItems.scalingMinTag    = {'DenCoefMin'};
dataTypeItems.scalingMaxTag    = {'DenCoefMax'};
dataTypeParamName = 'DenCoefDataTypeStr';
denCoefUdtSpec.hDlgSource = source;
denCoefUdtSpec.dtName     = dataTypeParamName;
denCoefUdtSpec.dtPrompt   = DAStudio.message('Simulink:dialog:DenCoefPrompt');
denCoefUdtSpec.dtTag      = dataTypeParamName;
denCoefUdtSpec.dtVal      = h.DenCoefDataTypeStr;
denCoefUdtSpec.dtaItems   = dataTypeItems;
denCoefUdtSpec.customAsstName = false;

% Denominator product
dataTypeItems = commonItems;
dataTypeItems.inheritRules  = Simulink.DataTypePrmWidget.getInheritList('IR_In');
dataTypeParamName = 'DenProductDataTypeStr';
denProdUdtSpec.hDlgSource = source;
denProdUdtSpec.dtName     = dataTypeParamName;
denProdUdtSpec.dtPrompt   = DAStudio.message('Simulink:dialog:DenProdPrompt');
denProdUdtSpec.dtTag      = dataTypeParamName;
denProdUdtSpec.dtVal      = h.DenProductDataTypeStr;
denProdUdtSpec.dtaItems   = dataTypeItems;
denProdUdtSpec.customAsstName = false;

% Denominator accumulator
dataTypeItems = commonItems;
dataTypeItems.inheritRules  = Simulink.DataTypePrmWidget.getInheritList('IR_In_Prod');
dataTypeParamName = 'DenAccumDataTypeStr';
denAccumUdtSpec.hDlgSource = source;
denAccumUdtSpec.dtName     = dataTypeParamName;
denAccumUdtSpec.dtPrompt   = DAStudio.message('Simulink:dialog:DenAccumPrompt');
denAccumUdtSpec.dtTag      = dataTypeParamName;
denAccumUdtSpec.dtVal      = h.DenAccumDataTypeStr;
denAccumUdtSpec.dtaItems   = dataTypeItems;
denAccumUdtSpec.customAsstName = false;

% Output
dataTypeItems = commonItems;
dataTypeItems.inheritRules  = Simulink.DataTypePrmWidget.getInheritList('In_IR');
dataTypeItems.scalingMinTag = {'OutMin'};
dataTypeItems.scalingMaxTag = {'OutMax'};
dataTypeParamName = 'OutDataTypeStr';
outUdtSpec.hDlgSource = source;
outUdtSpec.dtName     = dataTypeParamName;
outUdtSpec.dtPrompt   = DAStudio.message('Simulink:dialog:OutputPrompt');
outUdtSpec.dtTag      = dataTypeParamName;
outUdtSpec.dtVal      = h.OutDataTypeStr;
outUdtSpec.dtaItems   = dataTypeItems;
outUdtSpec.customAsstName = false;

% call getSPCDataTypeWidgets
udtSpecs = {stateUdtSpec ...
            numCoefUdtSpec numProdUdtSpec numAccumUdtSpec...
            denCoefUdtSpec denProdUdtSpec denAccumUdtSpec...
            outUdtSpec};
[promptWidgets, comboxWidgets, shwBtnWidgets, hdeBtnWidgets, dtaGUIWidgets] = ...
    Simulink.DataTypePrmWidget.getSPCDataTypeWidgets(source, udtSpecs, -1, []);
                    
uDTypeRowIdx = layoutRow + 1;
dtaGUIRowIdx = uDTypeRowIdx + 1;
desMinWidgets = cell(1, length(udtSpecs)); % preallocate (empty)
desMaxWidgets = cell(1, length(udtSpecs)); % preallocate (empty)

for idx = 1:length(udtSpecs)

    isEnabled = ~source.isHierarchySimulating;

    promptWidgets{idx}.RowSpan = [uDTypeRowIdx uDTypeRowIdx];
    promptWidgets{idx}.ColSpan = [dtaPrmColIdx dtaPrmColIdx];
    comboxWidgets{idx}.RowSpan = [uDTypeRowIdx uDTypeRowIdx];
    comboxWidgets{idx}.ColSpan = [dtaUDTColIdx dtaUDTColIdx];
    comboxWidgets{idx}.Enabled = isEnabled;
    shwBtnWidgets{idx}.RowSpan     = [uDTypeRowIdx uDTypeRowIdx];
    shwBtnWidgets{idx}.ColSpan     = [dtaBtnColIdx dtaBtnColIdx];
    shwBtnWidgets{idx}.MaximumSize = get_size('BtnMax');
    shwBtnWidgets{idx}.Enabled     = isEnabled;
    hdeBtnWidgets{idx}.RowSpan     = [uDTypeRowIdx uDTypeRowIdx];
    hdeBtnWidgets{idx}.ColSpan     = [dtaBtnColIdx dtaBtnColIdx];
    hdeBtnWidgets{idx}.MaximumSize = get_size('BtnMax');
    hdeBtnWidgets{idx}.Enabled     = isEnabled;

    % Possible Design Min/Max edit box widgets
    hasDesMinMax = ~isempty(udtSpecs{idx}.dtaItems.scalingMinTag);

    if hasDesMinMax
        
        [~, desMinWidgets{idx}] = create_widget(source, h, udtSpecs{idx}.dtaItems.scalingMinTag{1}, uDTypeRowIdx, desMinColIdx, desMinColIdx);
        desMinWidgets{idx}.RowSpan     = [uDTypeRowIdx uDTypeRowIdx];
        desMinWidgets{idx}.ColSpan     = [desMinColIdx desMinColIdx];
        desMinWidgets{idx}.MaximumSize = get_size('DesMMMax');
        
        [~, desMaxWidgets{idx}] = create_widget(source, h, udtSpecs{idx}.dtaItems.scalingMaxTag{1}, uDTypeRowIdx, desMaxColIdx, desMaxColIdx);
        desMaxWidgets{idx}.RowSpan     = [uDTypeRowIdx uDTypeRowIdx];
        desMaxWidgets{idx}.ColSpan     = [desMaxColIdx desMaxColIdx];
        desMaxWidgets{idx}.MaximumSize = get_size('DesMMMax');
    end
    
    % Data Type Assistant GUI widget
    dtaGUIWidgets{idx}.RowSpan = [dtaGUIRowIdx dtaGUIRowIdx];
    dtaGUIWidgets{idx}.ColSpan = [dtaUDTColIdx layoutCols];
    dtaGUIWidgets{idx}.Enabled = isEnabled;
    
    uDTypeRowIdx = uDTypeRowIdx + 2;
    dtaGUIRowIdx = uDTypeRowIdx + 1;
    
end

% Lock scale
layoutRow = dtaGUIRowIdx - 2;
layoutRow = layoutRow + 1;
lockOutScaleValue = create_widget(source, h, 'LockScale', layoutRow, 1, 1);
lockOutScaleValue.Visible = 1;
% Rounding mode
layoutRow = layoutRow + 1;
[roundPrompt roundValue] = create_widget(source, h, 'RndMeth', layoutRow, 1, 1);
% Saturate or wrap
layoutRow = layoutRow + 1;
SaturateOnIntegerOverflowValue = create_widget(source, h, ... 
                                 'SaturateOnIntegerOverflow', layoutRow, 1, 1);
% Assemble data type tab
dataTab.Name  =  DAStudio.message('Simulink:dialog:DataTypesTab');
dataTab.Items = {discText dtColText dtaColText minColText maxColText};
for idx = 1:length(udtSpecs)
    dataTab.Items = [dataTab.Items promptWidgets{idx} comboxWidgets{idx} ...
                     shwBtnWidgets{idx} hdeBtnWidgets{idx} dtaGUIWidgets{idx}];
    hasDesMinMax = isfield(udtSpecs{idx}.dtaItems,'scalingMinTag');
    if hasDesMinMax
        dataTab.Items = [dataTab.Items desMinWidgets{idx} desMaxWidgets{idx}];
    end
end
dataTab.Items = [dataTab.Items lockOutScaleValue ...
                 roundPrompt roundValue SaturateOnIntegerOverflowValue];

layoutRow = layoutRow + 2;
dataTab.LayoutGrid = [layoutRow layoutCols];
dataTab.RowStretch = [zeros(1, dataTab.LayoutGrid(1)-2) 1 0];
dataTab.ColStretch =  ones( 1, dataTab.LayoutGrid(2));

% State Attributes tab
% Reset the dialog layout, two columns for the prompt, three for the data
% Start the row counter over from zero
layoutRow    = 0; % Row counter.
layoutPrompt = 1; % Number of grid columns for the prompt widgets, when separate
layoutValue  = 4; % Number of grid columns for the value widgets, when separate
layoutCols = layoutPrompt + layoutValue; % The grid width

layoutRow = layoutRow + 1;
[StateIdentifierPrompt StateIdentifierValue] = create_widget(source, h, ...
    'StateIdentifier', layoutRow, layoutPrompt, layoutValue);
    
layoutRow = layoutRow + 1;
StateMustResolveToSigObjValue = create_widget(source, h, ...
    'StateMustResolveToSignalObject', layoutRow, layoutPrompt, layoutValue);
StateMustResolveToSigObjValue.Enabled = (isvarname(h.StateIdentifier) && ...
                                         strcmp(h.RTWStateStorageClass, 'Auto') && ...
                                         ~source.isHierarchySimulating);

layoutRow = layoutRow + 1;
[RTWStStoreClassPrompt RTWStStoreClassValue] = create_widget( ...
    source, h, 'RTWStateStorageClass', layoutRow, layoutPrompt, layoutValue);
RTWStStoreClassValue.Enabled = (isvarname(h.StateIdentifier) && ...
                                strcmp(h.StateMustResolveToSignalObject, 'off') && ...
                                ~source.isHierarchySimulating);

layoutRow = layoutRow + 1;
[RTWStStoreTypeQualifierPrompt RTWStStoreTypeQualifierValue] = ...
    create_widget(source, h, 'RTWStateStorageTypeQualifier', ...
                   layoutRow, layoutPrompt, layoutValue);
RTWStStoreTypeQualifierValue.Enabled = (RTWStStoreClassValue.Enabled && ...
                                        ~strcmp(h.RTWStateStorageClass,'Auto') && ...
                                        ~source.isHierarchySimulating);
         
% insert spacer on the last row     
layoutRow = layoutRow + 1;

statesTab.Name   = 'State Attributes';
statesTab.Items  = { ...
    ...% Prompts                    Data
    StateIdentifierPrompt           StateIdentifierValue  ...
                                    StateMustResolveToSigObjValue ...
    RTWStStoreClassPrompt           RTWStStoreClassValue  ...
    RTWStStoreTypeQualifierPrompt   RTWStStoreTypeQualifierValue  ...
                                    spacer };
                    
statesTab.LayoutGrid = [layoutRow layoutCols];
statesTab.ColStretch = [ones( 1, statesTab.LayoutGrid(2)-1) 0]; % Stretch all columns, but the last.
statesTab.RowStretch = [zeros(1, statesTab.LayoutGrid(1)-1) 1]; % Stretch only the last row.

% The constant part of the parameter group.
paramGrp.Name           = 'Parameters';
paramGrp.Type           = 'tab';
paramGrp.Tabs           = {mainTab, dataTab, statesTab};
paramGrp.RowSpan        = [2 2];
paramGrp.ColSpan        = [1 1];
paramGrp.Source         = h;

%------------------------------------------------------------------------------
% Assemble main dialog struct
%------------------------------------------------------------------------------
dlgStruct.DialogTitle   = ['Block Parameters: ' strrep(h.Name, sprintf('\n'), ' ')];
if strcmpi(h.BlockType,'DiscreteFilter')
    dlgStruct.DialogTag = 'DiscreteFilter';
else
    dlgStruct.DialogTag = 'DiscreteTransferFcn';
end
dlgStruct.Items         = {descGrp, paramGrp};
dlgStruct.LayoutGrid    = [2 1];
dlgStruct.RowStretch    = [0 1];
dlgStruct.HelpMethod    = 'slhelp';
dlgStruct.HelpArgs      = {h.Handle};
% Required for simulink/block sync ----
dlgStruct.PreApplyMethod = 'preApplyCallback';
dlgStruct.PreApplyArgs   = {'%dialog'};
dlgStruct.PreApplyArgsDT = {'handle'};
% Required for deregistration ---------
dlgStruct.CloseMethod       = 'closeCallback';
dlgStruct.CloseMethodArgs   = {'%dialog'};
dlgStruct.CloseMethodArgsDT = {'handle'};

% Disable the dialog in a library.
[~, isLocked] = source.isLibraryBlock(h);
if isLocked
  dlgStruct.DisableDialog = 1;
else
  dlgStruct.DisableDialog = 0;
end

end 

%==========================================================================
function size = get_size(what)
switch what
    case 'BtnMax'
        size = [(get_inch*5/12) 2^24-1];
    case 'DesMMMax'
        size = [get_inch 2^24-1];
    otherwise
        size = [0 0];
end
end
 
%==========================================================================
function dpi = get_inch
dpi = get(0,'ScreenPixelsPerInch');
end

% dtf_ddg.m

