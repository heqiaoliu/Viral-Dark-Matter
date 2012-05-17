function dlgStruct = interpndddg(source, h)
% INTERPNDDDG
%   Default DDG schema for Interpolation n-D block parameter dialog.
%

% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.6.19 $ $Date: 2010/05/20 03:14:28 $

isNotSimulating = ~source.isHierarchySimulating;

% Get scaling, inheritance rules and builtin types for output type.
dataTypeItems.scalingModes = Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB');
dataTypeItems.signModes = Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
dataTypeItems.builtinTypes = Simulink.DataTypePrmWidget.getBuiltinList('Num');
dataTypeItems.inheritRules = Simulink.DataTypePrmWidget.getInheritList('BP_TD2');
% Reuse for intermediate type, but modify inheritance list.
intermTypeItems = dataTypeItems;
intermTypeItems.inheritRules = Simulink.DataTypePrmWidget.getInheritList('IR_Out_TDT');
% Reuse for table type, modify scaling and inheritance rules.
tableTypeItems = dataTypeItems;
tableTypeItems.scalingModes = Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB_Best');
tableTypeItems.inheritRules = Simulink.DataTypePrmWidget.getInheritList('Out_TD');

% Top group is the block description
descTxt.Name            = h.BlockDescription;
descTxt.Type            = 'text';
descTxt.WordWrap        = true;

rowIdx = 1; 

descGrp.Name            = h.BlockType;
descGrp.Type            = 'group';
descGrp.Items           = {descTxt};
descGrp.RowSpan         = [1 1];
descGrp.ColSpan         = [1 1];

rowIdx = rowIdx + 1;

% Bottom group is the block parameters

NumDimValues                = create_widget(source, h, 'NumberOfTableDimensions',rowIdx, 2, 2);
NumDimValues.Type           = 'combobox';
NumDimValues.Entries        = {'1', '2', '3', '4'};
NumDimValues.Editable       = 1;
NumDimValues.ColSpan        = [1 10];

rowIdx = rowIdx + 1;

sourceLabel.Name = DAStudio.message('Simulink:blkprm_prompts:ParamSourceLabelId');
sourceLabel.RowSpan = [rowIdx rowIdx];
sourceLabel.ColSpan = [3 4];
sourceLabel.Type = 'text';

valueLabel.Name = DAStudio.message('Simulink:blkprm_prompts:ParamValueLabelId');
valueLabel.RowSpan = [rowIdx rowIdx];
valueLabel.ColSpan = [5 8];
valueLabel.Type = 'text';

rowIdx = rowIdx + 1;

tableValues  = create_widget(source, h, 'Table', rowIdx, 2, 2);
tableValues.ColSpan        = [5 8];

[tblSrcPrompt tableSource] = create_widget(source, h, 'TableSource', rowIdx, 2, 2);
tblSrcPrompt.Name          = tableValues.Name;
tblSrcPrompt.ColSpan       = [1 2];
tableSource.ColSpan        = [3 4];
tableSource.DialogRefresh  = true;

if isempty(h.TableSource)
    % Handle old blocks with unset TableSource value.
    wasDirty = get_param(bdroot(h.Handle), 'Dirty');
    h.TableSource = tableSource.Entries{1};
    set_param(bdroot(h.Handle), 'Dirty', wasDirty);
end
tableFromDialog            = strcmp(h.TableSource, tableSource.Entries{1});
tableValues = rmfield(tableValues, 'Name');

valueLabel.Visible         = tableFromDialog;

tableValues.Enabled        = tableFromDialog;
tableValues.Visible        = tableFromDialog;

tableValuesEdit.Name       = 'Edit...';
tableValuesEdit.Type       = 'pushbutton';
tableValuesEdit.RowSpan    = [rowIdx rowIdx];
tableValuesEdit.ColSpan    = [9 10];
tableValuesEdit.MatlabMethod = 'luteditorddg_cb';
tableValuesEdit.MatlabArgs = {'%dialog',h};
tableValuesEdit.Enabled    = tableFromDialog;
tableValuesEdit.Visible    = tableFromDialog;

rowIdx = rowIdx + 1;

% Table Group
TableGroup.Name = DAStudio.message('Simulink:blkprm_prompts:ParamGroupLabelId');
TableGroup.Type = 'group';
TableGroup.RowSpan = [1 3];
TableGroup.ColSpan = [1 10];
TableGroup.LayoutGrid = [1 10];
TableGroup.ColStretch = [0 0 0 0 1 1 1 1 0 0]; 

TableGroup.Items = {sourceLabel, valueLabel,NumDimValues, tblSrcPrompt, tableSource, tableValues, tableValuesEdit};


interp_popup                = create_widget(source, h, 'InterpMethod', rowIdx, 2, 2);
interp_popup.DialogRefresh  = true;
interp_popup.ColSpan = [1 10];

enableExtrapolation = strcmp(h.InterpMethod, interp_popup.Entries{2});

rowIdx = rowIdx + 1;

extrap_popup                = create_widget(source, h, 'ExtrapMethod', rowIdx, 2, 2);
extrap_popup.Enabled        = isNotSimulating && enableExtrapolation;
extrap_popup.Visible        = enableExtrapolation;
extrap_popup.DialogRefresh  = true;
extrap_popup.ColSpan = [1 10];

enableLastIndex = enableExtrapolation && strcmp(h.ExtrapMethod, extrap_popup.Entries{1});

rowIdx = rowIdx + 1;

rangeErr_popup              = create_widget(source, h, 'RangeErrorMode', rowIdx, 2, 2);
rangeErr_popup.ColSpan = [1 10];

rowIdx = rowIdx + 1;

checkCodeVal                = create_widget(source, h, 'CheckIndexInCode', rowIdx, 2, 2);

rowIdx = rowIdx + 1;

validIdxVal                 = create_widget(source, h, 'ValidIndexMayReachLast', rowIdx, 2, 2);
validIdxVal.Enabled         = isNotSimulating && enableLastIndex;
validIdxVal.Visible         = enableLastIndex;

rowIdx = rowIdx + 1;
 
selDimValues                = create_widget(source, h, 'NumSelectionDims', rowIdx, 2, 2);
selDimValues.Enabled        = isNotSimulating;
selDimValues.ColSpan = [1 10];

rowIdx = rowIdx + 1;
ts                  = create_widget(source, h, 'SampleTime', rowIdx, 2, 2);
ts.ColSpan          = [1 10];

rowIdx = rowIdx + 1;

spacer.Name    = '';
spacer.Type    = 'text';
spacer.RowSpan = [rowIdx rowIdx];
spacer.ColSpan = [1 10];

mainTab.Name       = 'Main';

mainTab.Items      = {TableGroup, ...
                    interp_popup,extrap_popup, ...
                    rangeErr_popup,checkCodeVal,validIdxVal,selDimValues,ts,spacer};

mainTab.LayoutGrid = [rowIdx 10];
mainTab.ColStretch = [0 0 1 1 1 1 1 1 0 0];
mainTab.RowStretch = [zeros(1, (rowIdx-1)) 1];

rowIdx = 1;

outMin               = start_property(source, h, 'OutMin');
% outMin.Type          = 'edit';
outMin.RowSpan       = [rowIdx rowIdx];
outMin.ColSpan       = [1 1];
outMin.Enabled       = isNotSimulating;
% % required for synchronization --------
% outMin.MatlabMethod  = 'slDialogUtil';
% outMin.MatlabArgs    = {source,'sync','%dialog','edit','%tag'};

outMax               = start_property(source, h, 'OutMax');
% outMax.Type          = 'edit';
outMax.RowSpan       = [rowIdx rowIdx];
outMax.ColSpan       = [2 2];
outMax.Enabled       = isNotSimulating;
% % required for synchronization --------
% outMax.MatlabMethod  = 'slDialogUtil';
% outMax.MatlabArgs    = {source,'sync','%dialog','edit','%tag'};

rowIdx = rowIdx + 1;

% Start LockScale here because we need the tag in the unified data type
lockOutScale = start_property(source, h, 'LockScale');
lockOutScale.Enabled = isNotSimulating;

% Data type tab.

% Add Min/Max and value tags to be used for on-dialog scaling
dataTypeItems.scalingMinTag = {outMin.Tag};
dataTypeItems.scalingMaxTag = {outMax.Tag};
dataTypeItems.scalingValueTags = {tableValues.Tag};

paramName = 'OutDataTypeStr';

% Get Widget for Unified dataType
% For those blocks whose dialogs are created in MATLAB code, the tag of the unified
% data type widget MUST be identical to the parameter name.
dataTypeGroup = Simulink.DataTypePrmWidget.getDataTypeWidget(source, ...
                                                             paramName, ...
                                                             xlate('Output data type:'), ...
                                                             paramName, ...
                                                             h.OutDataTypeStr, ...
                                                             dataTypeItems, ...
                                                             false);

dataTypeGroup.RowSpan = [rowIdx rowIdx];
dataTypeGroup.ColSpan = [1 2];      
dataTypeGroup.Enabled = isNotSimulating;

rowIdx = rowIdx + 1;

% (above) lockOutScale = start_property(h, 'LockScale');
lockOutScale.RowSpan        = [rowIdx rowIdx];
lockOutScale.ColSpan        = [1 2];

rowIdx = rowIdx + 1;

round                = start_property(source, h, 'RndMeth');
round.RowSpan        = [rowIdx rowIdx];
round.ColSpan        = [1 2];
round.Editable       = 0;
round.Enabled        = isNotSimulating;

% Saturate check box
rowIdx = rowIdx + 1;

saturate = start_property(source, h, 'SaturateOnIntegerOverflow');
saturate.RowSpan = [rowIdx rowIdx];
saturate.ColSpan = [1 2];
saturate.Editable = 1;
saturate.Enabled  = isNotSimulating;

% Required for spacer 
rowIdx = rowIdx + 1;

spacer.RowSpan          = [rowIdx rowIdx];
spacer.ColSpan          = [1 2];

dataTab.Name            = 'Signal Attributes';

dataTab.Items           = {outMin, outMax, dataTypeGroup, lockOutScale, round, saturate, spacer};

dataTab.LayoutGrid      = [rowIdx 2];
dataTab.RowStretch      = [zeros(1, (rowIdx-1)) 1];

% Table attributes tab.
rowIdx = 1;

tableMin               = start_property(source, h, 'TableMin');
% tableMin.Type          = 'edit';
tableMin.RowSpan       = [rowIdx rowIdx];
tableMin.ColSpan       = [1 1];
tableMin.Enabled       = isNotSimulating && tableFromDialog;
tableMin.Visible       = tableFromDialog;
% required for synchronization --------
% tableMin.MatlabMethod  = 'slDialogUtil';
% tableMin.MatlabArgs    = {source,'sync','%dialog','edit','%tag'};

tableMax               = start_property(source, h, 'TableMax');
% tableMax.Type          = 'edit';
tableMax.RowSpan       = [rowIdx rowIdx];
tableMax.ColSpan       = [2 2];
tableMax.Enabled       = isNotSimulating && tableFromDialog;
tableMax.Visible       = tableFromDialog;
% required for synchronization --------
% tableMax.MatlabMethod  = 'slDialogUtil';
% tableMax.MatlabArgs    = {source,'sync','%dialog','edit','%tag'};

rowIdx = rowIdx + 1;

tableTypeItems.scalingMinTag = {tableMin.Tag};
tableTypeItems.scalingMaxTag = {tableMax.Tag};
tableTypeItems.scalingValueTags = {tableValues.Tag};

paramName = 'TableDataTypeStr';

% Get Widget for Unified table data type
% For those blocks whose dialogs are created in MATLAB code, the tag of the unified
% data type widget MUST be identical to the parameter name.
tableTypeGroup = Simulink.DataTypePrmWidget.getDataTypeWidget(source, ...
                                                             paramName, ...
                                                             xlate(h.IntrinsicDialogParameters.(paramName).Prompt), ...
                                                             paramName, ...
                                                             h.(paramName), ...
                                                             tableTypeItems, ...
                                                             false);

tableTypeGroup.RowSpan = [rowIdx rowIdx];
tableTypeGroup.ColSpan = [1 2];      
tableTypeGroup.Enabled = isNotSimulating && tableFromDialog;
tableTypeGroup.Visible = tableFromDialog;

rowIdx = rowIdx + 1;

spacer.Name    = '';
spacer.Type    = 'text';
spacer.RowSpan = [rowIdx rowIdx];
spacer.ColSpan = [1 2];
 
tableTab.Name           = DAStudio.message('Simulink:dialog:TableAttributes');

if ~tableFromDialog;
    tableIsPortMessage.Name     = DAStudio.message('Simulink:dialog:TableIsPort');
    tableIsPortMessage.Type     = 'text';
    tableIsPortMessage.WordWrap = true;
    %tableIsPortMessage.Enabled  = ~tableFromDialog;
    %tableIsPortMessage.Visible  = ~tableFromDialog;
    %tableIsPortMessage.RowSpan  = [rowIdx rowIdx+1];
    tableIsPortMessage.RowSpan  = [2 2];
    tableIsPortMessage.ColSpan  = [1 2];

    tableTab.Items = {tableIsPortMessage, spacer};
    tableTab.RowStretch = [1 1];
else
    tableTab.Items      = {tableMin, tableMax, tableTypeGroup, spacer};
end

tableTab.LayoutGrid     = [rowIdx 2];
tableTab.RowStretch     = [zeros(1, (rowIdx-1)) 1];

% Intermediate attributes tab.
rowIdx = 1;

% intermMin               = start_property(source, h, 'IntermediateResultsMin');
% % intermMin.Type          = 'edit';
% intermMin.RowSpan       = [rowIdx rowIdx];
% intermMin.ColSpan       = [1 1];
% % required for synchronization --------
% % intermMin.MatlabMethod  = 'slDialogUtil';
% % intermMin.MatlabArgs    = {source,'sync','%dialog','edit','%tag'};
% 
% intermMax               = start_property(source, h, 'IntermediateResultsMax');
% % intermMax.Type          = 'edit';
% intermMax.RowSpan       = [rowIdx rowIdx];
% intermMax.ColSpan       = [2 2];
% % required for synchronization --------
% % intermMax.MatlabMethod  = 'slDialogUtil';
% % intermMax.MatlabArgs    = {source,'sync','%dialog','edit','%tag'};
% 
% rowIdx = rowIdx + 1;
% 
% intermTypeItems.scalingMinTag = {intermMin.Tag};
% intermTypeItems.scalingMaxTag = {intermMax.Tag};
% intermTypeItems.scalingValueTags = {tableValues.Tag};

paramName = 'IntermediateResultsDataTypeStr';

% Get Widget for Unified table data type
% For those blocks whose dialogs are created in MATLAB code, the tag of the unified
% data type widget MUST be identical to the parameter name.
intermTypeGroup = Simulink.DataTypePrmWidget.getDataTypeWidget(source, ...
                                                             paramName, ...
                                                             xlate(h.IntrinsicDialogParameters.(paramName).Prompt), ...
                                                             paramName, ...
                                                             h.(paramName), ...
                                                             intermTypeItems, ...
                                                             false);

intermTypeGroup.RowSpan = [rowIdx rowIdx];
intermTypeGroup.ColSpan = [1 2];      
intermTypeGroup.Enabled = isNotSimulating;

% Required for spacer 
rowIdx = rowIdx + 1;

spacer.RowSpan          = [rowIdx rowIdx];
spacer.ColSpan          = [1 2];

internalTab.Items           = {intermTypeGroup, spacer};%intermMin, intermMax, 
internalTab.Name            = DAStudio.message('Simulink:dialog:IntermediateAttributes');
internalTab.LayoutGrid      = [rowIdx 2];
internalTab.RowStretch      = [zeros(1, (rowIdx-1)) 1];

% Combine tabs into the parameter group.
paramGrp.Name           = 'Parameters';
paramGrp.Type           = 'tab';
paramGrp.Tabs           = {mainTab, dataTab, tableTab, internalTab};
paramGrp.RowSpan        = [2 2];
paramGrp.ColSpan        = [1 1];
paramGrp.Source         = h;

%-----------------------------------------------------------------------
% Assemble main dialog struct
%-----------------------------------------------------------------------
dlgStruct.DialogTitle   = ['Block Parameters: ' strrep(h.Name, sprintf('\n'), ' ')];
dlgStruct.DialogTag     = 'Interpolation_n-D';
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

[~, isLocked] = source.isLibraryBlock(h);
if isLocked
  dlgStruct.DisableDialog = 1;
else
  dlgStruct.DisableDialog = 0;
end

end % interpndddg

function property = start_property(source, h, propName)
% Start the property definition for a parameter.

% The ObjectProperty and the Tag are mostly the same.
property.ObjectProperty = propName;
property.Tag            = property.ObjectProperty;
% Extract the prompt string from the block itself.
property.Name           = h.IntrinsicDialogParameters.(propName).Prompt;
% Choose the proper dialog parameter type.
switch lower(h.IntrinsicDialogParameters.(propName).Type)
    case 'enum'
        property.Type         = 'combobox';
        property.Entries      = h.getPropAllowedValues(propName)';
        property.MatlabMethod = 'handleComboSelectionEvent';
    case 'boolean'
        property.Type         = 'checkbox';
        property.MatlabMethod = 'handleCheckEvent';
    otherwise
        property.Type         = 'edit';        
        property.MatlabMethod = 'handleEditEvent';
end

property.MatlabArgs = {source, '%value', find(strcmp(source.paramsMap, propName))-1, '%dialog'};
 
end % start_property
