function dlgstruct = aliastypeddg(h, name)
% ALIASTYPEDDG Dynamic dialog for Simulink alias type objects.

% To lauch this dialog in MATLAB, use:
%    >> a = Simulink.AliasType;
%    >> DAStudio.Dialog(a);    

% Copyright 2003-2008 The MathWorks, Inc.
% $Revision: 1.1.6.9 $

  rowIdx = 0;
  
  %-----------------------------------------------------------------------
  % First Row contains:
  % - dataTypeGroup (for BaseType)
  %-----------------------------------------------------------------------  
  rowIdx = rowIdx+1;
  % Use allowed values as built-ins explicit data type items
  % (e.g. "Enum: <class name>") from the end of the list
  allowedVals = h.getPropAllowedValues('BaseType');
  for idx = length(allowedVals):-1:1
      if ~isempty(findstr('fixdt', allowedVals{idx})) || ...
         ~isempty(findstr(': ', allowedVals{idx}))
          
          % Remove this item
          allowedVals(idx) = [];
      else
          % All of the remaining types are built-ins
          break;
      end
  end
  dataTypeItems.builtinTypes = allowedVals;
  
  % Simulink data supports enumerate data type 
  dataTypeItems.supportsEnumType = true;
  
  % Get Widget for Unified dataType
  dataTypeGroup = Simulink.DataTypePrmWidget.getDataTypeWidget(h, ...
                                                               'BaseType', ...
                                                               DAStudio.message('Simulink:dialog:AliasTypeBaseTypePrompt'), ...
                                                               'BaseType', ...
                                                               h.BaseType, ...
                                                               dataTypeItems, ...
                                                               false);
  dataTypeGroup.RowSpan = [rowIdx rowIdx];
  dataTypeGroup.ColSpan = [1 2];

  %-----------------------------------------------------------------------
  % Second Row contains:
  % - headerFile label widget
  % - headerFile edit field widget
  %-----------------------------------------------------------------------  
  rowIdx = rowIdx+1;
  headerFileLbl.Name = DAStudio.message('Simulink:dialog:DataTypeHeaderFilePrompt');
  headerFileLbl.Type = 'text';
  headerFileLbl.RowSpan = [rowIdx rowIdx];
  headerFileLbl.ColSpan = [1 1];
  headerFileLbl.Tag = 'HeaderFileLbl';
  
  headerFile.Name = '';
  headerFile.RowSpan = [rowIdx rowIdx];
  headerFile.ColSpan = [2 2];
  headerFile.Type = 'edit';
  headerFile.Tag = 'headerFile_tag';
  headerFile.ObjectProperty = 'HeaderFile';
  
  %-----------------------------------------------------------------------
  % Third Row contains:
  % - Description editarea widget
  %----------------------------------------------------------------------- 
  rowIdx = rowIdx+1;
  description.Name = DAStudio.message('Simulink:dialog:ObjectDescriptionPrompt');
  description.Type = 'editarea';
  description.Tag = 'description_tag';
  description.RowSpan = [rowIdx rowIdx];
  description.ColSpan = [1 2];
  description.ObjectProperty = 'Description';  
  
  %-----------------------------------------------------------------------
  % Assemble main dialog struct
  %-----------------------------------------------------------------------  
  dlgstruct.DialogTitle = [class(h), ': ', name];
  dlgstruct.Items = {dataTypeGroup, headerFileLbl, headerFile, description};
  dlgstruct.LayoutGrid = [rowIdx 2];
  dlgstruct.HelpMethod = 'helpview';
  dlgstruct.HelpArgs   = {[docroot '/mapfiles/simulink.map'], 'simulink_alias_type'};
  dlgstruct.RowStretch = [zeros(1,rowIdx-1), 1];
  dlgstruct.ColStretch = [0 1];
  
