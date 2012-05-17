
function dlgStruct = prelookupddg(source, h)
% PRELOOKUPDDG
%   Default DDG schema for prelookup block parameter dialog.
%   No Visible, Enabled and Refresh fields are specified in this file.
%   They will be handled by the dialog callback in pre_lookup.cpp file.

% Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.14.2.1 $ $Date: 2010/06/07 13:34:12 $

% Get Scaling, Inheritance rules and builtin types
% Index Unified DataType   
indexDataTypeItems.scalingModes = Simulink.DataTypePrmWidget.getScalingModeList('Int');
indexDataTypeItems.signModes    = Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
indexDataTypeItems.builtinTypes = Simulink.DataTypePrmWidget.getBuiltinList('Int');

% Fraction Unified DataType   
fractionDataTypeItems.scalingModes = Simulink.DataTypePrmWidget.getScalingModeList('BPt');
fractionDataTypeItems.signModes    = Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
fractionDataTypeItems.inheritRules = Simulink.DataTypePrmWidget.getInheritList('IR');
fractionDataTypeItems.builtinTypes = Simulink.DataTypePrmWidget.getBuiltinList('Float');

% Breakpoint Unified DataType
breakpointDataTypeItems.scalingModes = Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB_Best');
breakpointDataTypeItems.signModes    = Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
breakpointDataTypeItems.inheritRules = Simulink.DataTypePrmWidget.getInheritList('In_IR_TD');
breakpointDataTypeItems.builtinTypes = Simulink.DataTypePrmWidget.getBuiltinList('Num');
    
% Top group is the block description
descTxt.Name            = h.BlockDescription;
descTxt.Type            = 'text';
descTxt.WordWrap        = true;

rowIdx = 1; 

descGrp.Name            = h.BlockType;
descGrp.Type            = 'group';
descGrp.Items           = {descTxt};
descGrp.RowSpan         = [rowIdx rowIdx];
descGrp.ColSpan         = [1 1];

rowIdx = rowIdx + 1;

sourceLabel.Name = DAStudio.message('Simulink:blkprm_prompts:ParamSourceLabelId');
sourceLabel.RowSpan = [rowIdx rowIdx];
sourceLabel.ColSpan = [2 3];
sourceLabel.Type = 'text';

valueLabel.Name = DAStudio.message('Simulink:blkprm_prompts:ParamValueLabelId');
valueLabel.RowSpan = [rowIdx rowIdx];
valueLabel.ColSpan = [3 4];
valueLabel.Type = 'text';

rowIdx = rowIdx + 1;

% Bottom group is the block parameters
bpFromDlg = strcmp(h.BreakpointsDataSource, 'Dialog');

valueLabel.Visible = bpFromDlg;

BpDataValues  = create_widget(source, h, 'BreakpointsData', rowIdx, 2, 2);
BpDataValues.ColSpan          = [3 13];

[BpDataSourcePrompt BpDataSource] = create_widget(source, h, 'BreakpointsDataSource', rowIdx, 2, 2);

% BpDataSourcePrompt 
BpDataSourcePrompt.ColSpan       = [1 1];
BpDataSourcePrompt.Name   = BpDataValues.Name;

% BpDataSource
BpDataSource.ColSpan          = [2 2];
BpDataSource.MatlabMethod  = 'slDialogUtil';
BpDataSource.MatlabArgs    = {source,'sync','%dialog','edit','%tag'};

BpDataSource.DialogRefresh    = true;

% Now set the name BpDataValues
BpDataValues = rmfield(BpDataValues, 'Name'); 

BpDataValues.Visible          = bpFromDlg;
BpDataValues.Enabled          = bpFromDlg; 
BpDataValues.DialogRefresh    = true;

BpDataValuesEdit.Name       = 'Edit...';
BpDataValuesEdit.Type       = 'pushbutton';
BpDataValuesEdit.RowSpan    = [rowIdx rowIdx];
BpDataValuesEdit.ColSpan    = [14 15];
BpDataValuesEdit.MatlabMethod = 'luteditorddg_cb';
BpDataValuesEdit.MatlabArgs = {'%dialog',h};
BpDataValuesEdit.Enabled =  bpFromDlg;
BpDataValuesEdit.Visible =  bpFromDlg;

rowIdx = rowIdx + 1;

% Breakpoint Group
BreakpointGroup.Name = DAStudio.message('Simulink:blkprm_prompts:ParamGroupLabelId');
BreakpointGroup.Type = 'group';
BreakpointGroup.RowSpan = [1 3];
BreakpointGroup.ColSpan = [1 15];
BreakpointGroup.LayoutGrid = [1 4];
BreakpointGroup.ColStretch = [0 0 1 0]; 

BreakpointGroup.Items = {sourceLabel, valueLabel,BpDataSourcePrompt, BpDataSource, BpDataValues, BpDataValuesEdit};

indexSearch_popup                = start_property(source, h, 'IndexSearchMethod');
indexSearch_popup.RowSpan        = [rowIdx rowIdx];
indexSearch_popup.ColSpan        = [1 15];

rowIdx = rowIdx + 1;

prevIndexVal                = start_property(source, h, 'BeginIndexSearchUsingPreviousIndexResult');
prevIndexVal.RowSpan        = [rowIdx rowIdx];
prevIndexVal.ColSpan        = [1 3];
prevIndexVal.Visible        = ~strcmp(h.IndexSearchMethod,'Evenly spaced points');
prevIndexVal.Enabled        = ~strcmp(h.IndexSearchMethod,'Evenly spaced points');

rowIdx = rowIdx + 1;

indexOnlyVal                = start_property(source, h, 'OutputOnlyTheIndex');
indexOnlyVal.RowSpan        = [rowIdx rowIdx];
indexOnlyVal.ColSpan        = [1 3];

rowIdx = rowIdx + 1;

outRangeInput_popup                = start_property(source, h, 'ProcessOutOfRangeInput');
outRangeInput_popup.RowSpan        = [rowIdx rowIdx];
outRangeInput_popup.ColSpan        = [1 15];
outRangeInput_popup.DialogRefresh  = true;

rowIdx = rowIdx + 1;

useLastBpVal                = start_property(source, h, 'UseLastBreakpoint');
useLastBpVal.RowSpan        = [rowIdx rowIdx];
useLastBpVal.ColSpan        = [1 15];
useLastBpVal.Visible        = strcmp(h.ProcessOutOfRangeInput,'Clip to range');
useLastBpVal.Enabled        = strcmp(h.ProcessOutOfRangeInput,'Clip to range');

rowIdx = rowIdx + 1 ;

outRangeAction_popup                = start_property(source, h, 'ActionForOutOfRangeInput');
outRangeAction_popup.RowSpan        = [rowIdx rowIdx];
outRangeAction_popup.ColSpan        = [1 15];

rowIdx = rowIdx + 1;
ts                  = start_property(source, h, 'SampleTime');
ts.RowSpan          = [rowIdx rowIdx];
ts.ColSpan          = [1 15];
ts.Enabled          = ~source.isHierarchySimulating;

rowIdx = rowIdx + 1;

% Main Tab
spacer.Name    = '';
spacer.Type    = 'text';
spacer.RowSpan = [rowIdx rowIdx];
spacer.ColSpan = [1 15];

mainTab.Name       = 'Main';

mainTab.Items  = {BreakpointGroup, ...
                  indexSearch_popup,prevIndexVal, ...
                  indexOnlyVal, outRangeInput_popup,useLastBpVal,outRangeAction_popup,ts,spacer}; 
                    
mainTab.LayoutGrid = [rowIdx 15];
mainTab.ColStretch = [0 0 1 1 1 1 1 1 1 1 1 1 1 0 0];
mainTab.RowStretch = [zeros(1, (rowIdx-1)) 1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

rowIdx = 1;

% Get Widget for Index Unified dataType
indexDataTypeGroup = Simulink.DataTypePrmWidget.getDataTypeWidget(source, ...
                                                  'IndexDataTypeStr', ...
                                                  xlate('Index data type:'), 'IndexDataTypeStr', ...
                                                  h.IndexDataTypeStr, indexDataTypeItems, false);
indexDataTypeGroup.RowSpan = [rowIdx rowIdx];
indexDataTypeGroup.ColSpan = [1 2];     
indexDataTypeGroup.Enabled = ~source.isHierarchySimulating;

%----------------------------------------------------------------------------------------------
rowIdx = rowIdx + 1;    

% Start LockScale here because we need the tag in the unified data type
lockOutScale = start_property(source, h, 'LockScale');

paramName = 'FractionDataTypeStr';

% Get Widget for Fraction Unified dataType
% For those blocks whose dialogs are created in MATLAB code, the tag of the unified
% data type widget MUST be identical to the parameter name.
fractionDataTypeGroup = Simulink.DataTypePrmWidget.getDataTypeWidget(source, ...
                                                                     paramName, ...
                                                                     xlate('Fraction data type:'), ...
                                                                     paramName, ...
                                                                     h.FractionDataTypeStr, ...
                                                                     fractionDataTypeItems, ...
                                                                     false); 

fractionDataTypeGroup.RowSpan = [rowIdx rowIdx];
fractionDataTypeGroup.ColSpan = [1 2];   
fractionDataTypeGroup.Enabled = ~source.isHierarchySimulating;

% To set visibility for lock scale
%res = Simulink.DataTypePrmWidget.parseDataTypeString( h.FractionDataTypeStr, fractionDataTypeItems);
%lockOutScale.Visible = res.showLockScaling;

rowIdx = rowIdx + 1;

% (above) lockOutScale = start_property(h, 'LockScale');
lockOutScale.RowSpan        = [rowIdx rowIdx];
lockOutScale.ColSpan        = [1 2];

rowIdx = rowIdx + 1;

round                = start_property(source, h, 'RndMeth');
round.RowSpan        = [rowIdx rowIdx];
round.ColSpan        = [1 2];
round.Editable       = 0;

% Required for spacer
rowIdx = rowIdx + 1;

spacer.RowSpan          = [rowIdx rowIdx];
spacer.ColSpan          = [1 2];

dataTab.Name            = 'Signal Attributes';


dataTab.Items           = {indexDataTypeGroup, ...
                    fractionDataTypeGroup, lockOutScale, ...
                    round, spacer};


dataTab.LayoutGrid      = [rowIdx 2];
dataTab.ColStretch      = [1 0];
dataTab.RowStretch      = [zeros(1, (rowIdx-1)) 1];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

rowIdx = 1;
breakpointMin = start_property(source, h, 'BreakpointMin');
breakpointMin.RowSpan = [rowIdx rowIdx];
breakpointMin.ColSpan = [1 1];

breakpointMax = start_property(source, h, 'BreakpointMax');
breakpointMax.RowSpan = [rowIdx rowIdx];
breakpointMax.ColSpan = [2 2];

breakpointDataTypeItems.scalingMinTag = {breakpointMin.Tag};
breakpointDataTypeItems.scalingMaxTag = {breakpointMax.Tag};
breakpointDataTypeItems.scalingValueTags = {BpDataValues.Tag};

rowIdx = rowIdx + 1;

paramName = 'BreakpointDataTypeStr';

breakpointDataTypeGroup = Simulink.DataTypePrmWidget.getDataTypeWidget(source, ...
                                                                     paramName, ...
                                                                     xlate('Breakpoint data type:'), ...
                                                                     paramName, ...
                                                                     h.BreakpointDataTypeStr, ...
                                                                     breakpointDataTypeItems, ...
                                                                     false); 
breakpointDataTypeGroup.RowSpan = [rowIdx rowIdx];
breakpointDataTypeGroup.ColSpan = [1 2];                 
breakpointDataTypeGroup.Enabled = ~source.isHierarchySimulating;
% Required for spacer
rowIdx = rowIdx + 1;

spacer.Name    = '';
spacer.Type    = 'text';
spacer.RowSpan = [rowIdx rowIdx];
spacer.ColSpan = [1 2];

paramTab.Name  = 'Breakpoint Attributes';

if  ~bpFromDlg % Bp from port
    bpAttribHiddenPrompt.Name    = DAStudio.message('Simulink:dialog:BpAttributesHiddenPrompt');
    bpAttribHiddenPrompt.Type    = 'text';
    bpAttribHiddenPrompt.WordWrap = true;
    bpAttribHiddenPrompt.RowSpan  = [2  2];
    bpAttribHiddenPrompt.ColSpan = [1 2];
    paramTab.Items = {bpAttribHiddenPrompt, spacer};
    paramTab.RowStretch = [1 1];
else
    paramTab.Items = {breakpointMin, breakpointMax, breakpointDataTypeGroup, spacer};
end

paramTab.LayoutGrid = [rowIdx 2];
paramTab.RowStretch      = [zeros(1, (rowIdx-1)) 1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramGrp.Name           = 'Parameters';
paramGrp.Type           = 'tab';
paramGrp.Tabs           = {mainTab, dataTab, paramTab};
paramGrp.RowSpan        = [2 2];
paramGrp.ColSpan        = [1 1];
paramGrp.Source         = h;


%-----------------------------------------------------------------------
% Assemble main dialog struct
%-----------------------------------------------------------------------
dlgStruct.DialogTitle   = ['Block Parameters: ' strrep(h.Name, sprintf('\n'), ' ')];
dlgStruct.DialogTag    = 'PreLookup';
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

end % prelookupddg




%--------------------------------------------------------------------------------------------
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
 
if ~h.isTunableProperty(propName)
    property.Enabled = ~source.isHierarchySimulating;
end

end % start_property
