function dlgStruct = sqrt_ddg(source, h)
% SQRT_DDG
%   DDG schema for sqrt block parameter dialog.
%

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $

%     
% Top group is the block description
descTxt.Name     = h.BlockDescription;
descTxt.Type     = 'text';
descTxt.WordWrap = true;

descGrp.Name    = h.BlockType;
descGrp.Type    = 'group';
descGrp.Items   = {descTxt};
descGrp.RowSpan = [1 1];
descGrp.ColSpan = [1 1];
isNotSimulating = ~source.isHierarchySimulating;

isRSqrt      = strcmp(h.Operator, 'rSqrt');

funcSource          = start_property(source, h, 'Operator');
funcSource.RowSpan  = [1 1];
funcSource.ColSpan  = [1 2];
funcSource.Editable = 0;
funcSource.Enabled  = isNotSimulating;
funcSource.ToolTip  = DAStudio.message('Simulink:blocks:sqrtDlgFunction');

outSignalType          = start_property(source, h, 'OutputSignalType');
outSignalType.RowSpan  = [2 2];
outSignalType.ColSpan  = [1 2];
outSignalType.Editable = 0;
outSignalType.Enabled  = (isNotSimulating && ~isRSqrt);
outSignalType.ToolTip  = DAStudio.message('Simulink:blocks:sqrtDlgOutSignalType');

tsPrompt         = create_widget(source, h, 'SampleTime', 3, 2, 2);
tsPrompt.RowSpan = [3 3];
tsPrompt.ColSpan = [1 2];
tsPrompt.ToolTip = DAStudio.message('Simulink:blocks:sqrtDlgTs');
                               
bottomSpacer1.Name    = '';
bottomSpacer1.Type    = 'text';
bottomSpacer1.RowSpan = [4 4];
bottomSpacer1.ColSpan = [1 2];

                            

mainTab.Name       = 'Main';
mainTab.Items      = { ...
    funcSource         ...
    outSignalType      ...                       
    tsPrompt           ...
    bottomSpacer1 };
                    
mainTab.LayoutGrid = [4 2];
mainTab.ColStretch = [1 0];     % Stretch all columns, but the last.
mainTab.RowStretch = [0 0 0 1]; % Stretch only the last row.

% Signal Attributes 
SignalAttributes.Name   = 'Signal Attributes';

%%%%%%%%%%%%%%%%%
%% OutMin      %%
%%%%%%%%%%%%%%%%%

OutMin               = start_property(source,h, 'OutMin');
OutMin.RowSpan       = [1 1];
OutMin.ColSpan       = [1 1];
% required for synchronization --------
OutMin.MatlabMethod  = 'slDialogUtil';
OutMin.MatlabArgs    = {source,'sync','%dialog','edit','%tag'};
OutMin.Enabled       = isNotSimulating;

%%%%%%%%%%%%
%% OutMax %%
%%%%%%%%%%%%
OutMax               = start_property(source, h, 'OutMax');
OutMax.RowSpan       = [1 1];
OutMax.ColSpan       = [2 2];

OutMax.MatlabMethod  = 'slDialogUtil';
OutMax.MatlabArgs    = {source,'sync','%dialog','edit','%tag'};
OutMax.Enabled       = isNotSimulating;

% Get scaling, inheritance rules and builtin types for output type.
dataTypeItems.scalingModes = Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB');
dataTypeItems.signModes    = Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
dataTypeItems.builtinTypes = Simulink.DataTypePrmWidget.getBuiltinList('Num');
dataTypeItems.inheritRules = Simulink.DataTypePrmWidget.getInheritList('In_Sqrt');


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
dataTypeGroup.Visible = 1;

% Start LockScale here because we need the tag in the unified data type
lockOutScale              = start_property(source,h, 'LockScale');
lockOutScale.RowSpan      = [4 4];
lockOutScale.ColSpan      = [1 2];
% required for synchronization --------
lockOutScale.MatlabMethod = 'slDDGUtil';
lockOutScale.MatlabArgs   = {source,'sync','%dialog','checkbox','%tag', '%value'};
lockOutScale.Enabled      = isNotSimulating;


round              = start_property(source,h, 'RndMeth');
round.RowSpan      = [5 5];
round.ColSpan      = [1 2];
round.Editable     = 0;
round.MatlabMethod = 'slDDGUtil';
round.MatlabArgs   = {source,'sync','%dialog','combobox','%tag', '%value'};
round.Enabled       = isNotSimulating;

saturate          = start_property(source, h, 'SaturateOnIntegerOverflow');
saturate.RowSpan  = [6 6];
saturate.ColSpan  = [1 2];
saturate.Editable = 1;
saturate.Enabled   = isNotSimulating;

bottomSpacer2.Name    = '';
bottomSpacer2.Type    = 'text';
bottomSpacer2.RowSpan = [7 7];
bottomSpacer2.ColSpan = [1 2];

SignalAttributes.Items  = {OutMin , OutMax, dataTypeGroup, lockOutScale, ...
                           round, saturate, bottomSpacer2};
SignalAttributes.LayoutGrid = [7 2];
SignalAttributes.RowStretch = [zeros(1, 6) 1];


%
% Intermediate Attributes Tab
%
IntermAttributes.Name   = 'Algorithm';

% Intermediate results data type
IntermResults         =  start_property(source,h, 'IntermediateResultsDataTypeStr');
IntermResults.RowSpan = [1 1];
IntermResults.ColSpan = [1 2];
IntermResults.Enabled = (isNotSimulating && isRSqrt);
IntermResults.ToolTip = DAStudio.message('Simulink:blocks:sqrtDlgIntermResults');

% Method
MethodSource         = start_property(source,h, 'AlgorithmType');
MethodSource.RowSpan = [2 2];
MethodSource.ColSpan = [1 2];
MethodSource.Enabled = (isNotSimulating && isRSqrt);
MethodSource.ToolTip = DAStudio.message('Simulink:blocks:sqrtDlgMethod');

isNR = strcmp(h.AlgorithmType, 'Newton-Raphson');

% Number of Iterations
NumIterations          = start_property(source,h, 'Iterations');
NumIterations.RowSpan  = [3 3];
NumIterations.ColSpan  = [1 2];
NumIterations.Enabled  = (isNotSimulating && isRSqrt && isNR);
NumIterations.Editable = NumIterations.Enabled;
NumIterations.ToolTip  = DAStudio.message('Simulink:blocks:sqrtDlgNumIterations');

bottomSpacer3.Name    = '';
bottomSpacer3.Type    = 'text';
bottomSpacer3.RowSpan = [4 4];
bottomSpacer3.ColSpan = [1 2];

IntermAttributes.Items  = {IntermResults, MethodSource, ...
                           NumIterations, bottomSpacer3};
IntermAttributes.LayoutGrid = [4 2];
IntermAttributes.RowStretch = [zeros(1, 3) 1];

% Combine tabs into the parameter group.
paramGrp.Name           = 'Parameters';
paramGrp.Type           = 'tab';
paramGrp.Tabs           = {mainTab, SignalAttributes, IntermAttributes};

paramGrp.RowSpan        = [2 2];
paramGrp.ColSpan        = [1 1];
paramGrp.Source         = h;

 %-----------------------------------------------------------------------
% Assemble main dialog struct
%-----------------------------------------------------------------------
dlgStruct.DialogTitle   = ['Block Parameters: ' strrep(h.Name, sprintf('\n'), ' ')];
dlgStruct.DialogTag     = 'Sqrt';
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

end % sqrt_ddg   


function property = start_property(source, h, propName)
% Start the property definition for a parameter.

% The ObjectProperty and the Tag are mostly the same.
property.ObjectProperty = propName;
property.Tag            = property.ObjectProperty;
% Extract the prompt string from the block itself.
property.Name           = h.IntrinsicDialogParameters.(propName).Prompt;

property.Visible = 1;

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

