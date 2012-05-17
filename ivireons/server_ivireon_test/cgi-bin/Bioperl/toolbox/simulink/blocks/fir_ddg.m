function dlgStruct = fir_ddg(source, h)
% FIR_DDG
%   DDG schema for Discrete FIR Filter block parameter dialog.
%

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $

% Block settings
hasCoefDialog    = strcmpi(h.CoefSource,'Dialog parameters');
hasStateDTDialog = strcmpi(h.FirFiltStruct,'Lattice MA');
hasTapSumDTDialog = strcmpi(h.FirFiltStruct,'Direct form symmetric') ...
    || strcmpi(h.FirFiltStruct,'Direct form antisymmetric');

% Top group is the block description
descTxt.Name     = h.BlockDescription;
descTxt.Type     = 'text';
descTxt.WordWrap = true;

descGrp.Name     = 'Discrete FIR Filter';
descGrp.Type     = 'group';
descGrp.Items    = {descTxt};
descGrp.RowSpan  = [1 1];
descGrp.ColSpan  = [1 1];

% Reset the dialog layout, two columns for the prompt, three for the data.
layoutRow    = 0; % Row counter.
layoutPrompt = 1; % Number of grid columns for the prompt widgets, when separate.
layoutValue  = 4; % Number of grid columns for the value widgets, when separate.
layoutCols = layoutPrompt + layoutValue; % The grid width.

layoutRow = layoutRow + 1;
[coefSourcePrompt coefSourceValue] = create_widget(source, h, 'CoefSource', ...
                                          layoutRow, layoutPrompt, layoutValue);
coefSourceValue.DialogRefresh  = true;

layoutRow = layoutRow + 1;
[filtStructurePrompt filtStructureValue] = ...
    create_widget(source, h, 'FirFiltStruct', layoutRow, layoutPrompt, layoutValue);
filtStructureValue.DialogRefresh  = true;

layoutRow = layoutRow + 1;
[numeratorPrompt numeratorValue] = create_widget(source, h, ...
    'NumCoeffs', layoutRow, layoutPrompt, layoutValue);
if hasCoefDialog
    numeratorPrompt.Visible = true;
    numeratorPrompt.Enabled = true;
    numeratorValue.Visible  = true;
    numeratorValue.Enabled  = true;
else
    numeratorPrompt.Visible = false;
    numeratorPrompt.Enabled = false;
    numeratorValue.Visible  = false;
    numeratorValue.Enabled  = false;
end

layoutRow = layoutRow + 1;
[initialStatesPrompt initialStatesValue] = create_widget(source, h, ...
    'IC', layoutRow, layoutPrompt, layoutValue);    

layoutRow = layoutRow + 1;
[tsPrompt tsValue] = create_widget(source, h, 'SampleTime', ...
                            layoutRow, layoutPrompt, layoutValue);
                                
layoutRow = layoutRow + 1;
spacer.Name    = '';
spacer.Type    = 'text';
spacer.RowSpan = [layoutRow layoutRow];
spacer.ColSpan = [1         layoutCols];

mainTab.Name   = 'Main';

mainTab.Items  = { coefSourcePrompt coefSourceValue ...
                   filtStructurePrompt filtStructureValue};
if hasCoefDialog
    mainTab.Items = [mainTab.Items ...
                     numeratorPrompt numeratorValue];
end
 mainTab.Items = [mainTab.Items ...
                  initialStatesPrompt initialStatesValue  ...
                  tsPrompt            tsValue  ...
                  spacer ];
                    
mainTab.LayoutGrid = [layoutRow layoutCols];
mainTab.ColStretch = [ones( 1, mainTab.LayoutGrid(2)-1) 0]; % Stretch all columns, but the last.
mainTab.RowStretch = [zeros(1, mainTab.LayoutGrid(1)-1) 1]; % Stretch only the last row.



% Data Type Attributes tab
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
commonItems.signModes      = Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
commonItems.builtinTypes   = Simulink.DataTypePrmWidget.getBuiltinList('Int');
commonItems.scalingValueTags = {};
commonItems.scalingMinTag      = {};
commonItems.scalingMaxTag      = {};
commonItems.lockScalingTag = 'LockScale';

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

% tap sum
dataTypeItems = commonItems;
dataTypeItems.inheritRules  = Simulink.DataTypePrmWidget.getInheritList('In');
dataTypeParamName = 'TapSumDataTypeStr';
tapsumUdtSpec.hDlgSource = source;
tapsumUdtSpec.dtName     = dataTypeParamName;
tapsumUdtSpec.dtPrompt   = DAStudio.message('Simulink:dialog:TapSumPrompt');
tapsumUdtSpec.dtTag      = dataTypeParamName;
tapsumUdtSpec.dtVal      = h.TapSumDataTypeStr;
tapsumUdtSpec.dtaItems   = dataTypeItems;
tapsumUdtSpec.customAsstName = false;

% Coefficient
dataTypeItems = commonItems;
dataTypeItems.inheritRules  = Simulink.DataTypePrmWidget.getInheritList('InWL');
dataTypeItems.scalingModes  = Simulink.DataTypePrmWidget.getScalingModeList('BPt_Best');
dataTypeItems.scalingValueTags = {'NumCoeffs'};
dataTypeItems.scalingMinTag = {'CoefMin'};
dataTypeItems.scalingMaxTag = {'CoefMax'};
dataTypeParamName = 'CoefDataTypeStr';
numCoefUdtSpec.hDlgSource = source;
numCoefUdtSpec.dtName     = dataTypeParamName;
numCoefUdtSpec.dtPrompt   = DAStudio.message('Simulink:dialog:NumCoefPrompt');
numCoefUdtSpec.dtTag      = dataTypeParamName;
numCoefUdtSpec.dtVal      = h.CoefDataTypeStr;
numCoefUdtSpec.dtaItems   = dataTypeItems;
numCoefUdtSpec.customAsstName = false;

% Product
dataTypeItems = commonItems;
dataTypeItems.inheritRules  = Simulink.DataTypePrmWidget.getInheritList('IR_In');
dataTypeParamName = 'ProductDataTypeStr';
numProdUdtSpec.hDlgSource = source;
numProdUdtSpec.dtName     = dataTypeParamName;
numProdUdtSpec.dtPrompt   = DAStudio.message('Simulink:dialog:ProdPrompt');
numProdUdtSpec.dtTag      = dataTypeParamName;
numProdUdtSpec.dtVal      = h.ProductDataTypeStr;
numProdUdtSpec.dtaItems   = dataTypeItems;
numProdUdtSpec.customAsstName = false;

% Accumulator
dataTypeItems = commonItems;
dataTypeItems.inheritRules  = Simulink.DataTypePrmWidget.getInheritList('In_Prod');
dataTypeParamName = 'AccumDataTypeStr';
numAccumUdtSpec.hDlgSource = source;
numAccumUdtSpec.dtName     = dataTypeParamName;
numAccumUdtSpec.dtPrompt   = DAStudio.message('Simulink:dialog:AccumPrompt');
numAccumUdtSpec.dtTag      = dataTypeParamName;
numAccumUdtSpec.dtVal      = h.AccumDataTypeStr;
numAccumUdtSpec.dtaItems   = dataTypeItems;
numAccumUdtSpec.customAsstName = false;

% Output
dataTypeItems = commonItems;
dataTypeItems.inheritRules  = Simulink.DataTypePrmWidget.getInheritList('In_Accum');
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
udtSpecs = {tapsumUdtSpec numCoefUdtSpec numProdUdtSpec numAccumUdtSpec ...
            stateUdtSpec outUdtSpec};

[promptWidgets, comboxWidgets, shwBtnWidgets, hdeBtnWidgets, dtaGUIWidgets] = ...
    Simulink.DataTypePrmWidget.getSPCDataTypeWidgets(source, udtSpecs, -1, []);
                    
uDTypeRowIdx = layoutRow + 1;
dtaGUIRowIdx = uDTypeRowIdx + 1;
desMinWidgets = cell(1, length(udtSpecs)); % preallocate (empty)
desMaxWidgets = cell(1, length(udtSpecs)); % preallocate (empty)
isEnabled     = ~source.isHierarchySimulating;

for idx = 1:length(udtSpecs)
    promptWidgets{idx}.RowSpan = [uDTypeRowIdx uDTypeRowIdx];
    promptWidgets{idx}.ColSpan = [dtaPrmColIdx dtaPrmColIdx];
    comboxWidgets{idx}.RowSpan = [uDTypeRowIdx uDTypeRowIdx];
    comboxWidgets{idx}.ColSpan = [dtaUDTColIdx dtaUDTColIdx];
    comboxWidgets{idx}.Enabled = isEnabled;
    shwBtnWidgets{idx}.RowSpan = [uDTypeRowIdx uDTypeRowIdx];
    shwBtnWidgets{idx}.ColSpan = [dtaBtnColIdx dtaBtnColIdx];
    shwBtnWidgets{idx}.MaximumSize = get_size('BtnMax');
    shwBtnWidgets{idx}.Enabled = isEnabled;
    hdeBtnWidgets{idx}.RowSpan = [uDTypeRowIdx uDTypeRowIdx];
    hdeBtnWidgets{idx}.ColSpan = [dtaBtnColIdx dtaBtnColIdx];
    hdeBtnWidgets{idx}.MaximumSize = get_size('BtnMax');
    hdeBtnWidgets{idx}.Enabled = isEnabled;

    % Possible Design Min/Max edit box widgets
    hasDesMinMax = ~isempty(udtSpecs{idx}.dtaItems.scalingMinTag);
    if hasDesMinMax
        [~, desMinWidgets{idx}] = create_widget(source, h, udtSpecs{idx}.dtaItems.scalingMinTag{1}, uDTypeRowIdx, desMinColIdx, desMinColIdx);
        desMinWidgets{idx}.RowSpan = [uDTypeRowIdx uDTypeRowIdx];
        desMinWidgets{idx}.ColSpan = [desMinColIdx desMinColIdx];
        desMinWidgets{idx}.MaximumSize = get_size('DesMMMax');
        
        [~, desMaxWidgets{idx}] = create_widget(source, h, udtSpecs{idx}.dtaItems.scalingMaxTag{1}, uDTypeRowIdx, desMaxColIdx, desMaxColIdx);
        desMaxWidgets{idx}.RowSpan = [uDTypeRowIdx uDTypeRowIdx];
        desMaxWidgets{idx}.ColSpan = [desMaxColIdx desMaxColIdx];
        desMaxWidgets{idx}.MaximumSize = get_size('DesMMMax');
    end
    
    % Data Type Assistant GUI widget
    dtaGUIWidgets{idx}.RowSpan = [dtaGUIRowIdx dtaGUIRowIdx];
    dtaGUIWidgets{idx}.ColSpan = [dtaUDTColIdx layoutCols];
    dtaGUIWidgets{idx}.Enabled = isEnabled;
    
    uDTypeRowIdx = uDTypeRowIdx + 2;
    dtaGUIRowIdx = uDTypeRowIdx + 1;
end

[TAPSUM COEF STATE] = deal(1,2,5);
if hasTapSumDTDialog
    promptWidgets{TAPSUM}.Visible = true; promptWidgets{TAPSUM}.Enabled = true;
    comboxWidgets{TAPSUM}.Visible = true;  comboxWidgets{TAPSUM}.Enabled = isEnabled;
    shwBtnWidgets{TAPSUM}.Enabled = isEnabled;
    hdeBtnWidgets{TAPSUM}.Visible = ~shwBtnWidgets{TAPSUM}.Visible; 
    hdeBtnWidgets{TAPSUM}.Enabled = isEnabled;
else
    promptWidgets{TAPSUM}.Visible = false; promptWidgets{TAPSUM}.Enabled = false;
    comboxWidgets{TAPSUM}.Visible = false; comboxWidgets{TAPSUM}.Enabled = false;
    shwBtnWidgets{TAPSUM}.Visible = false; shwBtnWidgets{TAPSUM}.Enabled = false;
    hdeBtnWidgets{TAPSUM}.Visible = false; hdeBtnWidgets{TAPSUM}.Enabled = false;
    dtaGUIWidgets{TAPSUM}.Visible = false; dtaGUIWidgets{TAPSUM}.Enabled = false;
end
if hasCoefDialog
    promptWidgets{COEF}.Visible = true; promptWidgets{COEF}.Enabled = true;
    comboxWidgets{COEF}.Visible = true;  comboxWidgets{COEF}.Enabled = isEnabled;
    shwBtnWidgets{COEF}.Enabled = isEnabled;
    hdeBtnWidgets{COEF}.Visible = ~shwBtnWidgets{COEF}.Visible; 
    hdeBtnWidgets{COEF}.Enabled = isEnabled;
    desMinWidgets{COEF}.Visible = true; desMinWidgets{COEF}.Enabled = isEnabled;
    desMaxWidgets{COEF}.Visible = true; desMaxWidgets{COEF}.Enabled = isEnabled;
else
    promptWidgets{COEF}.Visible = false; promptWidgets{COEF}.Enabled = false;
    comboxWidgets{COEF}.Visible = false; comboxWidgets{COEF}.Enabled = false;
    shwBtnWidgets{COEF}.Visible = false; shwBtnWidgets{COEF}.Enabled = false;
    hdeBtnWidgets{COEF}.Visible = false; hdeBtnWidgets{COEF}.Enabled = false;
    desMinWidgets{COEF}.Visible = false; desMinWidgets{COEF}.Enabled = false;
    desMaxWidgets{COEF}.Visible = false; desMaxWidgets{COEF}.Enabled = false;
    dtaGUIWidgets{COEF}.Visible = false; dtaGUIWidgets{COEF}.Enabled = false;
end
if hasStateDTDialog
    promptWidgets{STATE}.Visible = true; promptWidgets{STATE}.Enabled = true;
    comboxWidgets{STATE}.Visible = true;  comboxWidgets{STATE}.Enabled = isEnabled;
    shwBtnWidgets{STATE}.Enabled = isEnabled;
    hdeBtnWidgets{STATE}.Visible = ~shwBtnWidgets{STATE}.Visible; 
    hdeBtnWidgets{STATE}.Enabled = isEnabled;
else
    promptWidgets{STATE}.Visible = false; promptWidgets{STATE}.Enabled = false;
    comboxWidgets{STATE}.Visible = false; comboxWidgets{STATE}.Enabled = false;
    shwBtnWidgets{STATE}.Visible = false; shwBtnWidgets{STATE}.Enabled = false;
    hdeBtnWidgets{STATE}.Visible = false; hdeBtnWidgets{STATE}.Enabled = false;
    dtaGUIWidgets{STATE}.Visible = false; dtaGUIWidgets{STATE}.Enabled = false;
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


% The constant part of the parameter group.
paramGrp.Name           = 'Parameters';
paramGrp.Type           = 'tab';
paramGrp.Tabs           = {mainTab, dataTab};
paramGrp.RowSpan        = [2 2];
paramGrp.ColSpan        = [1 1];
paramGrp.Source         = h;

%------------------------------------------------------------------------------
% Assemble main dialog struct
%------------------------------------------------------------------------------
dlgStruct.DialogTitle   = ['Block Parameters: ' strrep(h.Name, sprintf('\n'), ' ')];
dlgStruct.DialogTag     = 'DiscreteFir';
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

% fir_ddg.m
