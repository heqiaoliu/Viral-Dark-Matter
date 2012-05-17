function dlgStruct = direct_lookupnd_ddg(source, h)
% DIRECT_LOOKUPND_DDG
%   DDG schema for Direct Lookup n-D block parameter dialog.
%

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $

% Get scaling, inheritance rules and builtin types for table type.    
tableTypeItems.scalingModes = Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB_Best');
tableTypeItems.signModes = Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
tableTypeItems.builtinTypes = Simulink.DataTypePrmWidget.getBuiltinList('NumBool');
tableTypeItems.inheritRules = Simulink.DataTypePrmWidget.getInheritList('In_TD');

% Top group is the block description
descTxt.Name            = h.BlockDescription;
descTxt.Type            = 'text';
descTxt.WordWrap        = true;


descGrp.Name            = 'Direct Lookup Table (n-D)'; % h.BlockType;
descGrp.Type            = 'group';
descGrp.Items           = {descTxt};
descGrp.RowSpan         = [1 1];
descGrp.ColSpan         = [1 1];

% Reset the dialog layout, two columns for the prompt, three for the data.
layoutRow    = 0; % Row counter.
layoutPrompt = 2; % Number of grid columns for the prompt widgets, when separate.
layoutValue  = 3; % Number of grid columns for the value widgets, when separate.
layoutCols = layoutPrompt + layoutValue; % The grid width.

% Bottom group is the block parameters
layoutRow = layoutRow + 1;
[numDimPrompt numDimValue]      = start_property(source, h, 'NumberOfTableDimensions', ...
                                                 layoutRow, layoutPrompt, layoutValue);
numDimValue.Type                = 'combobox';
numDimValue.Entries             = {'1', '2', '3', '4'};
numDimValue.Editable            = 1;


layoutRow = layoutRow + 1;
[outputDimsPrompt ...
            outputDimsValue]   = start_property(source, h, 'InputsSelectThisObjectFromTable', ...
                                                 layoutRow, layoutPrompt, layoutValue);
layoutRow = layoutRow + 1;
tableAsInputValue                = start_property(source, h, 'TableIsInput', ...
                                                 layoutRow, layoutPrompt, layoutValue);
tableAsInputValue.DialogRefresh  = true;

layoutRow = layoutRow + 1;
[tablePrompt]       = start_property(source, h, 'Table', ...
                                                 layoutRow, layoutPrompt, layoutValue - 1); % Leave room for the edit button.

% This widget goes in the same row as the Table values.
tableValuesEdit.Name            = 'Edit...';
tableValuesEdit.Type            = 'pushbutton';
tableValuesEdit.RowSpan         = [layoutRow  layoutRow];
tableValuesEdit.ColSpan         = [layoutCols layoutCols];
tableValuesEdit.MatlabMethod    = 'luteditorddg_cb';
tableValuesEdit.MatlabArgs      = {'%dialog',h};

if (strcmp(h.TableIsInput,'on')) % table is input.
    tablePrompt.Visible = false;
    tablePrompt.Enabled = false;
    tableValuesEdit.Visible = false;
    tableValuesEdit.Enabled = false;    
else % table is parameter
    % Always enabled when visible, because it is tunable.
    tablePrompt.Visible = true;
    tablePrompt.Enabled = true;
    tableValuesEdit.Visible = true;
    tableValuesEdit.Enabled = true;
end

layoutRow = layoutRow + 1;
[rangeErrPrompt rangeErr_popup] = start_property(source, h, 'ActionForOutOfRangeInput', ...
                                                layoutRow, layoutPrompt, layoutValue);
layoutRow = layoutRow + 1;
[tsPrompt tsValue] = start_property(source, h, 'SampleTime', ...
                                    layoutRow, layoutPrompt, layoutValue);

layoutRow = layoutRow + 1;
spacer.Name    = '';
spacer.Type    = 'text';
spacer.RowSpan = [layoutRow layoutRow];
spacer.ColSpan = [1         layoutCols];

mainTab.Name       = 'Main';
mainTab.Items      = { ...
    ...% Prompts       Data
    numDimPrompt       numDimValue  ...
    outputDimsPrompt   outputDimsValue  ...
                       tableAsInputValue  ...
    tablePrompt         ...
                       tableValuesEdit  ...
    rangeErrPrompt     rangeErr_popup  ...
    tsPrompt           tsValue  ...
                       spacer };
                    
mainTab.LayoutGrid = [layoutRow layoutCols];
mainTab.ColStretch = [ones( 1, mainTab.LayoutGrid(2)-1) 0]; % Stretch all columns, but the last.
mainTab.RowStretch = [zeros(1, mainTab.LayoutGrid(1)-1) 1]; % Stretch only the last row.


% Table attributes tab.
layoutRow    = 1; % Row counter.
layoutPrompt = 2; % Number of grid columns for the prompt widgets, when separate.
layoutValue  = 2; % Number of grid columns for the value widgets, when separate.
layoutCols = layoutPrompt + layoutValue; % The grid width.
layoutStartPrompt = 1;

[tableMinPrompt tableMin]              = start_property(source, h, 'TableMin', layoutRow, ...
                                                        1, 1, layoutStartPrompt);

[tableMaxPrompt tableMax]              = start_property(source, h, 'TableMax', layoutRow, ...
                                                         layoutPrompt+1, 1, layoutStartPrompt+layoutValue);

tableTypeItems.scalingMinTag = {tableMin.Tag};
tableTypeItems.scalingMaxTag = {tableMax.Tag};
tableTypeItems.scalingValueTags = {tablePrompt.Tag};

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
layoutRow = layoutRow + 1;

tableTypeGroup.RowSpan = [layoutRow  layoutRow];
tableTypeGroup.ColSpan = [1 4];      

layoutRow = layoutRow + 1;
lockOutScaleValue = start_property(source, h, 'LockScale', ...
                                   layoutRow, layoutPrompt, layoutValue);

if (strcmp(h.TableIsInput,'on')) % table is input.
    tableMinPrompt.Enabled = false;
    tableMin.Enabled = false;
    tableMaxPrompt.Enabled = false;
    tableMax.Enabled = false;
    tableTypeGroup.Enabled = false;
    lockOutScaleValue.Enabled = false;
else % table is parameter
    tableMinPrompt.Enabled = ~source.isHierarchySimulating;
    tableMin.Enabled = ~source.isHierarchySimulating;
    tableMaxPrompt.Enabled = ~source.isHierarchySimulating;
    tableMax.Enabled = ~source.isHierarchySimulating;
    tableTypeGroup.Enabled = ~source.isHierarchySimulating;
    lockOutScaleValue.Enabled = ~source.isHierarchySimulating;
end

layoutRow = layoutRow + 1;
% spacer
spacer.Name    = '';
spacer.Type    = 'text';
spacer.RowSpan          = [layoutRow  layoutRow];
spacer.ColSpan          = [1 4];

tableTab.Items          = { tableMinPrompt, tableMin, ...
                            tableMaxPrompt, tableMax, ...
                            tableTypeGroup, lockOutScaleValue, spacer};
tableTab.Name           = DAStudio.message('Simulink:dialog:TableAttributes');
tableTab.LayoutGrid     = [layoutRow layoutCols];
tableTab.RowStretch = [zeros(1, tableTab.LayoutGrid(1)-1) 1]; % Stretch only the last row.

if (strcmp(h.TableIsInput,'on')) % table is input.
                                 % the dialog parameters are hidden
    tableAttribHiddenPrompt.Name    = DAStudio.message('Simulink:dialog:TableAttributesHiddenPrompt');
    tableAttribHiddenPrompt.Type    = 'text';
    tableAttribHiddenPrompt.RowSpan  = [2  2];
    tableAttribHiddenPrompt.ColSpan = [1 4];
    tableTab.Items = { tableAttribHiddenPrompt, spacer};
end

% The constant part of the parameter group.
paramGrp.Name           = 'Parameters';
paramGrp.Type           = 'tab';
paramGrp.Tabs           = {mainTab, tableTab};
paramGrp.RowSpan        = [2 2];
paramGrp.ColSpan        = [1 1];
paramGrp.Source         = h;

%-----------------------------------------------------------------------
% Assemble main dialog struct
%-----------------------------------------------------------------------
dlgStruct.DialogTitle   = ['Block Parameters: ' strrep(h.Name, sprintf('\n'), ' ')];
dlgStruct.DialogTag     = 'LookupNDDirect';
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

end % direct_lookupnd_ddg

%==========================================================================
function [out1 out2] = start_property(source, h, propName, ...
                                      layoutRow, layoutPrompt, layoutValue, layoutStartPrompt)
% Start the property definition for a parameter.
% If there is one output, it is the prompt and the value widget.
% If there are two outputs, the first is the prompt widget and the second
% is the value widget.

% Indirect access to the output parameters.
% The local temp is a struct that whose fields are set indirectly through
% the prompt and value variables.
if nargout == 1
    % One output: Combined prompt and value.
    prompt = 'out1';
    value  = 'out1';
else
    % Two outputs: Separate prompt and value.
    prompt = 'out1';
    value  = 'out2';
    temp.out1.Type = 'text';
end  

if nargin <= 6
    % start of prompt is specified and should not default to 1
    layoutStartPrompt = 1;
end

% The ObjectProperty and the Tag are related.
temp.(value).ObjectProperty = propName;
temp.(value).Tag            = temp.(value).ObjectProperty;
% Extract the prompt string from the block itself.
temp.(prompt).Name          = h.IntrinsicDialogParameters.(propName).Prompt;
% Choose the proper dialog parameter type.
switch lower(h.IntrinsicDialogParameters.(propName).Type)
    case 'enum'
        temp.(value).Type         = 'combobox';
        temp.(value).Entries      = h.getPropAllowedValues(propName)';
        temp.(value).MatlabMethod = 'handleComboSelectionEvent';
        temp.(value).Editable     = 0;
    case 'boolean'
        temp.(value).Type         = 'checkbox';
        temp.(value).MatlabMethod = 'handleCheckEvent';
    otherwise
        temp.(value).Type         = 'edit';        
        temp.(value).MatlabMethod = 'handleEditEvent';
end

temp.(value).MatlabArgs = {source, '%value', find(strcmp(source.paramsMap, propName))-1, '%dialog'};
 
if ~h.isTunableProperty(propName)
    temp.(value).Enabled = ~source.isHierarchySimulating;
end

out1 = temp.out1;
out1.RowSpan = [layoutRow layoutRow];

if nargout > 1
  out2 = temp.out2;
  out2.RowSpan = [layoutRow layoutRow];
  out1.ColSpan = [layoutStartPrompt layoutPrompt];
  out2.ColSpan = [(layoutPrompt + 1) (layoutPrompt + layoutValue)];
  out1.Tag   = [out2.ObjectProperty '_Prompt_Tag'];
  out1.Buddy = out2.Tag;
else
  out1.ColSpan = [layoutStartPrompt (layoutPrompt + layoutValue)];
end

end % start_property
