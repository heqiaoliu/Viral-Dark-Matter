function dlgStruct = lookup1dddg(source, h)
% LOOKUP1DDDG
%   Default DDG schema for 1-D Lookup block parameter dialog.
%

% Copyright 2003-2009 The MathWorks, Inc.
% $Revision: 1.1.6.20 $ $Date: 2009/05/14 17:49:15 $

    
% Get Scaling, Inheritance rules and builtin types
dataTypeItems.scalingModes = Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB');

dataTypeItems.signModes = Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
dataTypeItems.inheritRules = Simulink.DataTypePrmWidget.getInheritList('BP_In');
dataTypeItems.builtinTypes = Simulink.DataTypePrmWidget.getBuiltinList('Num');

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

% Bottom group is the block parameters
inputValues                = start_property(h, 'InputValues');
inputValues.Type           = 'edit';
inputValues.RowSpan        = [rowIdx rowIdx];
inputValues.ColSpan        = [1 4];
% required for synchronization --------
inputValues.MatlabMethod   = 'slDDGUtil';
inputValues.MatlabArgs     = {source,'sync','%dialog','edit','%tag', '%value'};

inputValuesEdit.Name       = 'Edit...';
inputValuesEdit.Type       = 'pushbutton';
inputValuesEdit.RowSpan    = [rowIdx rowIdx];
inputValuesEdit.ColSpan    = [5 5];
inputValuesEdit.MatlabMethod = 'luteditorddg_cb';
inputValuesEdit.MatlabArgs = {'%dialog',h};


rowIdx = rowIdx + 1;

outputValues             = start_property(h, 'Table');
outputValues.Type        = 'edit';
outputValues.RowSpan     = [rowIdx rowIdx];
outputValues.ColSpan     = [1 4];
% required for synchronization --------
outputValues.MatlabMethod = 'slDDGUtil';
outputValues.MatlabArgs  = {source,'sync','%dialog','edit','%tag', '%value'};

rowIdx = rowIdx + 1;

lookup_popup                = start_property(h, 'LookUpMeth');
lookup_popup.Type           = 'combobox';
lookup_popup.Entries        = h.getPropAllowedValues('LookUpMeth')';
lookup_popup.RowSpan        = [rowIdx rowIdx];
lookup_popup.ColSpan        = [1 5];
lookup_popup.DialogRefresh  = 1;
lookup_popup.Editable       = 0;
lookup_popup.Enabled        = ~source.isHierarchySimulating;
% required for synchronization --------
lookup_popup.MatlabMethod   = 'slDDGUtil';
lookup_popup.MatlabArgs     = {source,'sync','%dialog','combobox','%tag', '%value'};

rowIdx = rowIdx + 1;

ts                  = start_property(h, 'SampleTime');
ts.Type             = 'edit';
ts.RowSpan          = [rowIdx rowIdx];
ts.ColSpan          = [1 5];
ts.Enabled          = ~source.isHierarchySimulating;
% required for synchronization --------
ts.MatlabMethod     = 'slDDGUtil';
ts.MatlabArgs       = {source,'sync','%dialog','edit','%tag', '%value'};

rowIdx = rowIdx + 1;

spacer.Name    = '';
spacer.Type    = 'text';
spacer.RowSpan = [rowIdx rowIdx];
spacer.ColSpan = [1 5];

mainTab.Name       = 'Main';
mainTab.Items      = {inputValues,inputValuesEdit,outputValues,lookup_popup,ts,spacer};
mainTab.LayoutGrid = [rowIdx rowIdx];
mainTab.ColStretch = [1 1 1 1 0];
mainTab.RowStretch = [zeros(1, (rowIdx-1))  1];


rowIdx = 1;

outMin               = start_property(h, 'OutMin');
outMin.Type          = 'edit';
outMin.RowSpan       = [rowIdx rowIdx];
outMin.ColSpan       = [1 1];
outMin.Enabled       = ~source.isHierarchySimulating;
% required for synchronization --------
outMin.MatlabMethod  = 'slDialogUtil';
outMin.MatlabArgs    = {source,'sync','%dialog','edit','%tag'};

outMax               = start_property(h, 'OutMax');
outMax.Type          = 'edit';
outMax.RowSpan       = [rowIdx rowIdx];
outMax.ColSpan       = [2 2];
outMax.Enabled       = ~source.isHierarchySimulating;
% required for synchronization --------
outMax.MatlabMethod  = 'slDialogUtil';
outMax.MatlabArgs    = {source,'sync','%dialog','edit','%tag'};
rowIdx = rowIdx + 1;

% Start LockScale here because we need the tag in the unified data type
lockOutScale = start_property(h, 'LockScale');

% Add Min/Max and value tags to be used for on-dialog scaling
dataTypeItems.scalingMinTag = {outMin.Tag};
dataTypeItems.scalingMaxTag = {outMax.Tag};
dataTypeItems.scalingValueTags = {outputValues.Tag}; 

paramName = 'OutDataTypeStr';

% Get Widget for Unified dataType
% For those blocks whose dialogs are created in m-code, the tag of the unified
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
dataTypeGroup.Enabled = ~source.isHierarchySimulating;

rowIdx = rowIdx +  1;

lockOutScale.Type           = 'checkbox';
lockOutScale.DialogRefresh  = 1;
lockOutScale.RowSpan        = [rowIdx rowIdx];
lockOutScale.ColSpan        = [1 2];
lockOutScale.Enabled        = ~source.isHierarchySimulating;
% required for synchronization --------
lockOutScale.MatlabMethod   = 'slDDGUtil';
lockOutScale.MatlabArgs     = {source,'sync','%dialog','checkbox','%tag', '%value'};

rowIdx = rowIdx + 1;

round                = start_property(h, 'RndMeth');
round.Type           = 'combobox';
round.Entries        = h.getPropAllowedValues('RndMeth')';
round.RowSpan        = [rowIdx rowIdx];
round.ColSpan        = [1 2];
round.Editable       = 0;
% round.Mode         = 1;
round.DialogRefresh  = 1;
round.Enabled        = ~source.isHierarchySimulating;
% required for synchronization --------
round.MatlabMethod = 'slDDGUtil';
round.MatlabArgs   = {source,'sync','%dialog','combobox','%tag', '%value'};

rowIdx = rowIdx + 1;

saturate                = start_property(h, 'SaturateOnIntegerOverflow');
saturate.Type           = 'checkbox';
saturate.RowSpan        = [rowIdx rowIdx];
saturate.ColSpan        = [1 2];
saturate.Enabled        = ~source.isHierarchySimulating;
% required for synchronization --------
saturate.MatlabMethod   = 'slDDGUtil';
saturate.MatlabArgs     = {source,'sync','%dialog','checkbox','%tag', '%value'};

% Required for spacer
rowIdx = rowIdx + 1;

spacer         = [];
spacer.Name    = '';
spacer.Type    = 'text';
spacer.RowSpan = [rowIdx rowIdx];
spacer.ColSpan = [1 2];

dataTab.Name            = 'Signal Attributes';
dataTab.Items           = {outMin, outMax, dataTypeGroup, lockOutScale, round, saturate,spacer};

dataTab.LayoutGrid      = [rowIdx 2];
dataTab.RowStretch      = [zeros(1, (rowIdx-1)) 1];

paramGrp.Name           = 'Parameters';
paramGrp.Type           = 'tab';
paramGrp.Tabs           = {mainTab, dataTab};
paramGrp.RowSpan        = [2 2];
paramGrp.ColSpan        = [1 1];
paramGrp.Source         = h;

%-----------------------------------------------------------------------
% Assemble main dialog struct
%-----------------------------------------------------------------------
dlgStruct.DialogTitle   = ['Block Parameters: ' strrep(h.Name, sprintf('\n'), ' ')];
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

end % lookup1dddg

function property = start_property(h, propName)
% Start the property definition for a parameter.

% The ObjectProperty and the Tag are mostly the same.
property.ObjectProperty = propName;
property.Tag            = property.ObjectProperty;
% Extract the prompt string from the block itself.
property.Name           = h.IntrinsicDialogParameters.(propName).Prompt;

end % start_property
