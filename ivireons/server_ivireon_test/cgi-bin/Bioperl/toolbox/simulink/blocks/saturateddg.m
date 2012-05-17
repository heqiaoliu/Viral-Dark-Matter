function dlgStruct = saturateddg(source, h)
%  SATURATEDDG
%   Default DDG schema for Saturate block parameter dialog.
%

%   Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ 

% Top group is the block description
descTxt.Name            = h.BlockDescription;
descTxt.Type            = 'text';
descTxt.WordWrap        = true;
isNotSimulating = ~source.isHierarchySimulating;

descGrp.Name            = h.BlockType;
descGrp.Type            = 'group';
descGrp.Items           = {descTxt};
descGrp.RowSpan         = [1 1];
descGrp.ColSpan         = [1 1];
rowIdx = 1; 
spacer.Name    = '';
spacer.Type    = 'text';
spacer.RowSpan = [rowIdx rowIdx];
spacer.ColSpan = [1 5];

ulFromDlg = strcmp(h.UpperLimitSource, 'Dialog');
llFromDlg = strcmp(h.LowerLimitSource, 'Dialog');
% Saturation limits Group
%    sP                  Source                  Value    
%    UpperLimit:     [ UpperLimitSource   ]   [ UpperLimitValues  ]
%    LowerLimit :    [ LowerLimitSource   ]   [ LowerLimitValues  ]
%
%    Note: sP = spacer

%%%%%%%%%%%%%%%
% sP : spacer %
%%%%%%%%%%%%%%%
sP.Name    = '';
sP.Type    = 'text';
sP.RowSpan = [1 1];
sP.ColSpan = [1 1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Upper Limit Prompt, Source and Value %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[UpperLimitSrcPrompt UpperLimitSource] = create_widget(source, h, 'UpperLimitSource', rowIdx, 2, 2);

% UpperLimitSrcPrompt 
UpperLimitSrcPrompt.RowSpan       = [2 2];
UpperLimitSrcPrompt.ColSpan       = [1 1];

% UpperLimitSource
UpperLimitSource.RowSpan          = [2 2];
UpperLimitSource.ColSpan          = [2 2];
UpperLimitSource.MatlabMethod  = 'slDialogUtil';
UpperLimitSource.MatlabArgs    = {source,'sync','%dialog','edit','%tag'};

UpperLimitValues  = create_widget(source, h, 'UpperLimit', rowIdx, 2, 2);
UpperLimitValues.RowSpan          = [2 2];
UpperLimitValues.ColSpan          = [3 3];
% UpperLimitValues.Tag = 'Upper limit:';

% Set the prompt to be the UpperLimitValue name: "Upper limit:"
UpperLimitSrcPrompt.Name   = UpperLimitValues.Name;

% Now set the name UpperLimitValues
UpperLimitValues.Name = ''; 

UpperLimitSource.DialogRefresh    = true;

UpperLimitValues.Visible          = ulFromDlg;
UpperLimitValues.DialogRefresh    = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Lower Limit Prompt, Source and Value %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[LowerLimitSrcPrompt LowerLimitSource] = create_widget(source, h, 'LowerLimitSource', rowIdx, 2, 2);

% LowerLimitSrcPrompt
LowerLimitSrcPrompt.RowSpan       = [3 3]; 
LowerLimitSrcPrompt.ColSpan       = [1 1]; 

% LowerLimitSource
LowerLimitSource.RowSpan          = [3 3]; 
LowerLimitSource.ColSpan          = [2 2]; 

LowerLimitValues  = create_widget(source, h, 'LowerLimit', rowIdx, 2, 2);
LowerLimitValues.RowSpan          = [3 3]; 
LowerLimitValues.ColSpan          = [3 3]; 
% LowerLimitValues.Tag = 'Lower limit:';

% Set the prompt to be the LowerLimitValue name: "Lower limit:"
LowerLimitSrcPrompt.Name     = LowerLimitValues.Name;

% Now set the name LowerLimitValues
LowerLimitValues.Name = '';

LowerLimitSource.DialogRefresh    = true;
LowerLimitValues.Visible          = llFromDlg;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Treat As Gain when linearizing %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LinearizeAsGain  = create_widget(source, h, 'LinearizeAsGain', rowIdx, 2, 2);
LinearizeAsGain.RowSpan       = [3 3];
LinearizeAsGain.ColSpan       = [1 5];

LinearizeAsGain.RowSpan       = [4 4]; % new
LinearizeAsGain.ColSpan       = [1 5];

LinearizeAsGain.Enabled        = (ulFromDlg && llFromDlg);
% LinearizeAsGain.Tag = 'Treat as gain when linearizing';

%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Enable Zero Crossing %%
%%%%%%%%%%%%%%%%%%%%%%%%%%
ZeroCross                = create_widget(source, h, 'ZeroCross', rowIdx, 2, 2);
ZeroCross.RowSpan       = [4 4];
ZeroCross.RowSpan       = [5 5]; % N
ZeroCross.ColSpan       = [1 5];
% ZeroCross.Tag = 'Enable zero-crossing detection';

ZeroCross.Enabled =  (~strcmp(get_param(bdroot(h.Handle),'SolverType'), 'Fixed-step')) && (~strcmp(get_param(bdroot(h.Handle),'ZeroCrossControl'),'DisableAll'));
ZeroCross.DialogRefresh    = true;

%%%%%%%%%%%%%%%%%
%% Sample Time %%
%%%%%%%%%%%%%%%%%
ts               = create_widget(source, h, 'SampleTime', rowIdx, 2, 2);
ts.RowSpan       = [5 5];
ts.RowSpan       = [6 6];
ts.ColSpan       = [1 5];
%ts.Tag = 'Sample time (-1 for inherited):';

%%%%%%%%%%%%%%%%%%
%% Tabs         %%
%%%%%%%%%%%%%%%%%%

%% Main Tab %%
spacer.Name    = '';
spacer.Type    = 'text';
spacer.RowSpan = [1 1];
spacer.ColSpan = [4 5];

spacer1.Name    = '';
spacer1.Type    = 'text';
spacer1.RowSpan = [2 2];
spacer1.ColSpan = [4 5];

bottomSpacer.Name    = '';
bottomSpacer.Type    = 'text';
bottomSpacer.RowSpan = [6 6];
bottomSpacer.ColSpan = [1 5];

% Saturation limits Group
SaturationGroup.Name = 'Saturation limits';
SaturationGroup.Type = 'group';
SaturationGroup.RowSpan = [UpperLimitSrcPrompt.RowSpan(1) LowerLimitValues.RowSpan(2)];
SaturationGroup.ColSpan = [1 3];
SaturationGroup.LayoutGrid = [2 3];
SaturationGroup.ColStretch = [0 0 1]; 

sourceLabel.Name = 'Source';
sourceLabel.RowSpan = [1 1];
sourceLabel.ColSpan = [2 2];
sourceLabel.Type = 'text';

valueLabel.Name = 'Value';
valueLabel.RowSpan = [1 1];
valueLabel.ColSpan = [3 3];
valueLabel.Type = 'text';

% Value Label Visibility
valueLabel.Visible = ulFromDlg || llFromDlg;

if ulFromDlg || llFromDlg
    SaturationGroup.Items = { sP, sourceLabel, valueLabel,...
                             UpperLimitSrcPrompt, UpperLimitSource, UpperLimitValues,...
                             LowerLimitSrcPrompt, LowerLimitSource, LowerLimitValues};
else
     SaturationGroup.Items = { sP, sourceLabel, valueLabel,...
                         UpperLimitSrcPrompt, UpperLimitSource, spacer,...
                         LowerLimitSrcPrompt, LowerLimitSource, spacer1 };
end


mainTab.Name   = 'Main';
mainTab.Items  = {SaturationGroup, ...                     
                  LinearizeAsGain, ...
                  ZeroCross, ...
                  ts...,
                  bottomSpacer};
mainTab.LayoutGrid = [6 3];
mainTab.ColStretch = [0 0 1];
mainTab.RowStretch = [zeros(1, 5) 1];

%% Signal Attributes %%
SignalAttributes.Name   = 'Signal Attributes';
%%%%%%%%%%%%%%%%%
%% OutMin %%
%%%%%%%%%%%%%%%%%

OutMin               = start_property(source,h, 'OutMin');
OutMin.RowSpan       = [1 1];
OutMin.ColSpan       = [1 1];
% required for synchronization --------
OutMin.MatlabMethod  = 'slDialogUtil';
OutMin.MatlabArgs    = {source,'sync','%dialog','edit','%tag'};
OutMin.Visible = true;
%%%%%%%%%%%%
%% OutMax %%
%%%%%%%%%%%%
OutMax               = start_property(source, h, 'OutMax');
OutMax.RowSpan       = [1 1];
OutMax.ColSpan       = [2 2];

OutMax.MatlabMethod  = 'slDialogUtil';
OutMax.MatlabArgs    = {source,'sync','%dialog','edit','%tag'};

% Get scaling, inheritance rules and builtin types for output type.
dataTypeItems.scalingModes = Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB');

dataTypeItems.signModes = Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
dataTypeItems.inheritRules = Simulink.DataTypePrmWidget.getInheritList('BP_In');
dataTypeItems.builtinTypes = Simulink.DataTypePrmWidget.getBuiltinList('Num');


% Add Min/Max and value tags to be used for on-dialog scaling
dataTypeItems.scalingMinTag = {OutMin.Tag};
dataTypeItems.scalingMaxTag = {OutMax.Tag};


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
dataTypeGroup.RowSpan = [3 3];
dataTypeGroup.ColSpan = [1 2];      
dataTypeGroup.Enabled = isNotSimulating;

% Start LockScale here because we need the tag in the unified data type
lockOutScale = start_property(source,h, 'LockScale');
lockOutScale.Enabled = isNotSimulating;
lockOutScale.RowSpan        = [4 4];
lockOutScale.ColSpan        = [1 2];
% required for synchronization --------
lockOutScale.MatlabMethod   = 'slDDGUtil';
lockOutScale.MatlabArgs     = {source,'sync','%dialog','checkbox','%tag', '%value'};


round                = start_property(source,h, 'RndMeth');
round.RowSpan        = [5 5];
round.ColSpan        = [1 2];
round.Editable       = 0;
round.Enabled        = isNotSimulating;
round.MatlabMethod = 'slDDGUtil';
round.MatlabArgs   = {source,'sync','%dialog','combobox','%tag', '%value'};

SignalAttributes.Items  = {OutMin , OutMax, dataTypeGroup, lockOutScale, round};
SignalAttributes.LayoutGrid = [5 2];
SignalAttributes.RowStretch      = [zeros(1, 5) 1];

% Combine tabs into the parameter group.
paramGrp.Name           = 'Parameters';
paramGrp.Type           = 'tab';
paramGrp.Tabs           = {mainTab, SignalAttributes};

paramGrp.RowSpan        = [2 2];
paramGrp.ColSpan        = [1 1];
paramGrp.Source         = h;

%-----------------------------------------------------------------------
% Assemble main dialog struct
%-----------------------------------------------------------------------
dlgStruct.DialogTitle   = ['Block Parameters: ' strrep(h.Name, sprintf('\n'), ' ')];
dlgStruct.DialogTag     = 'Saturation';
dlgStruct.DialogTag     = 'Saturate';
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

% End of function saturateddg

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

% End of function start_property
