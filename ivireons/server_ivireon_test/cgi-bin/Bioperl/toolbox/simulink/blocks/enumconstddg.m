function dlgStruct = enumconstddg(source, h)
% ENUMCONSTDDG Dynamic dialog for enumerated constant block.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/09/09 21:39:13 $

  isNotSimulating = ~source.isHierarchySimulating;
  valueStr = h.Value;
  dtStr    = h.OutDataTypeStr;
  
  %-----------------------------------------------------------------------
  % First Row contains:
  % - block description group
  %-----------------------------------------------------------------------  
  rowIdx = 1;
  
  descTxt.Name     = DAStudio.message('Simulink:blocks:EnumConstBlockDescription');
  descTxt.Type     = 'text';
  descTxt.WordWrap = true;

  descGrp.Name     = DAStudio.message('Simulink:blocks:EnumConstBlockType');
  descGrp.Type     = 'group';
  descGrp.Items    = {descTxt};
  descGrp.RowSpan  = [rowIdx rowIdx];
  descGrp.ColSpan  = [1 1];

  %-----------------------------------------------------------------------
  % Second Row contains:
  % - editfield for name of enumerated data type
  %-----------------------------------------------------------------------  
  rowIdx = rowIdx+1;
  typeNameOptions.supportsEnumType = true;
  typeNameOptions.allowsExpression = false;
  typeName = Simulink.DataTypePrmWidget.getDataTypeWidget(source, ...        % Source
                'OutDataTypeStr', ...                                        % ObjectProperty
                DAStudio.message('Simulink:blocks:EnumConstTypePrompt'), ... % Prompt
                'OutDataTypeStr', ...                                        % Tag
                dtStr, ...                                                   % Value
                typeNameOptions, ...                                         % Options
                false);                                                      % DTA on
  typeName.RowSpan = [rowIdx rowIdx];
  typeName.ColSpan = [1 1];
  % Redraw dialog if data type changes
  for idx = 1:length(typeName.Items)
    if strcmp(typeName.Items{idx}.Tag, 'OutDataTypeStr')
      typeName.Items{idx}.DialogRefresh = true;
    end
  end
  typeName.Enabled = isNotSimulating;
  
  %-----------------------------------------------------------------------
  % Third Row contains:
  % - combobox for names of enumerated values
  %-----------------------------------------------------------------------  
  rowIdx               = rowIdx+1;
  value.Name           = DAStudio.message('Simulink:blocks:EnumConstValuePrompt');
  value.RowSpan        = [rowIdx rowIdx];
  value.ColSpan        = [1 1];
  value.Type           = 'combobox';
  value.Source         = h;
  value.ObjectProperty = 'Value';
  value.Tag            = 'Value';
  value.Editable       = true;
  value.Entries        = l_GetListOfAllowableValues(dtStr);
  % If current value is not on the list of allowable values
  % ==> include current value in pulldown (it could be an expression)
  if (~isempty(value.Entries) && ...
      isempty(find(strcmp(value.Entries, valueStr), 1)))
      value.Entries = [{valueStr}; value.Entries];
  end

  %-----------------------------------------------------------------------
  % Fourth Row contains:
  % - edit field for sample time
  %-----------------------------------------------------------------------  
  rowIdx = rowIdx+1;
  sampleTime.Name = DAStudio.message('Simulink:blocks:EnumConstSampleTimePrompt');
  sampleTime.RowSpan = [rowIdx rowIdx];
  sampleTime.ColSpan = [1 1];
  sampleTime.Type = 'edit';
  sampleTime.Source = h;
  sampleTime.ObjectProperty = 'SampleTime';
  sampleTime.Tag = 'SampleTime';
  sampleTime.Enabled = isNotSimulating;
      
  %-----------------------------------------------------------------------
  % Last Row contains a spacer
  %-----------------------------------------------------------------------  
  rowIdx = rowIdx + 1;
  spacer.Name    = '';
  spacer.Type    = 'text';
  spacer.RowSpan = [rowIdx rowIdx];
  spacer.ColSpan = [1 1];

  %-----------------------------------------------------------------------
  % Assemble main dialog struct
  %-----------------------------------------------------------------------  
  dlgStruct.DialogTitle = DAStudio.message('Simulink:blocks:EnumConstBlockType');
  dlgStruct.Items = {descGrp, typeName, value, sampleTime, spacer};
  dlgStruct.LayoutGrid = [rowIdx 1];
  dlgStruct.RowStretch = [zeros(1, (rowIdx-1))  1];
  dlgStruct.ColStretch = 1;
  dlgStruct.HelpMethod = 'slhelp';
  dlgStruct.HelpArgs   = {h.Handle};
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

  
%==============================================================================
% SUBFUNCTIONS:
%==============================================================================
function enumNames = l_GetListOfAllowableValues(dtStr)
% Get list of allowable values

  try
    className = enumconst_cb('GetClassName', dtStr);
    
    [~, enumNames] = enumeration(className);
    for idx = 1:length(enumNames)
      enumNames{idx} = [className, '.', enumNames{idx}];
    end
  catch e %#ok
    % Swallow errors
    enumNames = {DAStudio.message('Simulink:blocks:EnumConstValueForInvalidDataType')};
  end

%EOF

