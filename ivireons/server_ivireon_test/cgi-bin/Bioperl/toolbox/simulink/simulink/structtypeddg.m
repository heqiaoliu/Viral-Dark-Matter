function dlgstruct = structtypeddg(h, name)
% STRUCTTYPEDDG Dynamic dialog for Simulink StructType objects.

% To lauch this dialog in MATLAB, use:
%    >> a = Simulink.StructType;
%    >> a.Elements = Simulink.StructElement;    
%    >> DAStudio.Dialog(a);

% Copyright 2003-2006 The MathWorks, Inc.
% $Revision: 1.1.6.11 $

  DA_TABLE_SUPPORT = 1;
  
  if (DA_TABLE_SUPPORT)
    %-----------------------------------------------------------------------
    % First Row contains:
    % - elements groupbox with
    % - elements table widget
    %-----------------------------------------------------------------------  
    
    tableData = {};
    if ~isempty(h.Elements)
      tableData = cell(length(h.Elements), 4);
      for i=1:length(h.Elements)
        val = h.Elements(i);
        tableData{i, 1} = val.Name;
        tableData{i, 2} = num2str(val.Dimensions);
        tableData{i, 3} = val.DataType;
        tableData{i, 4} = val.Complexity;
      end
    end
    
    structtable.Type = 'table';
    structtable.Tag  = 'StructElements';
    structtable.Size = [length(h.Elements) 4];
    structtable.Grid = 1;
    structtable.HeaderVisibility = [0 1];
    structtable.ColHeader = {DAStudio.message('Simulink:dialog:StructtypeStructtableColHeaderName'), ...
                             DAStudio.message('Simulink:dialog:StructtypeStructtableColHeaderDimension'), ...
                             DAStudio.message('Simulink:dialog:StructtypeStructtableColHeaderDataBusType'), ...
                             DAStudio.message('Simulink:dialog:StructtypeStructtableColHeaderComplexity')};
    structtable.Enabled = 0;
    structtable.Data = tableData;
    
    elementsgrp.Name =  DAStudio.message('Simulink:dialog:StructtypeElementsgrpName');
    elementsgrp.RowSpan = [1 1];
    elementsgrp.ColSpan = [1 2];
    elementsgrp.Type = 'group';
    elementsgrp.Flat = 1;
    elementsgrp.Items = {structtable};
    elementsgrp.Tag = 'Elementsgrp';
  
  else
    %-----------------------------------------------------------------------
    % First Row contains:
    % - elements label widget
    % - elements fields text widget
    %-----------------------------------------------------------------------  
    elementsLbl.Name = DAStudio.message('Simulink:dialog:StructtypeElementsLblName');
    elementsLbl.RowSpan = [1 1];
    elementsLbl.ColSpan = [1 1];
    elementsLbl.Type = 'text';
    elementsLbl.Tag = 'ElementsLbl';
    
    elementsVal.RowSpan = [1 1];
    elementsVal.ColSpan = [2 2];
    elementsVal.Type = 'text';
    elementsVal.Tag = 'ElementsVal';
    
    if ~isempty(h.Elements)
      val = '';
      for i=1:length(h.Elements)
        val= [val, h.Elements(i).Name, ' '];
      end;
      elementsVal.Name = val;
    else
      elementsVal.Name = DAStudio.message('Simulink:dialog:StructtypeElementsValNameEmpty');
      elementsVal.Italic = 1;
    end
  
  end
  
  %-----------------------------------------------------------------------
  % Second Row contains:
  % - headerFile label widget
  % - headerFile edit field widget
  %-----------------------------------------------------------------------
  headerFileLbl.Name = DAStudio.message('Simulink:dialog:StructtypeHeaderFileLblName');
  headerFileLbl.Type = 'text';
  headerFileLbl.RowSpan = [2 2];
  headerFileLbl.ColSpan = [1 1];
  headerFileLbl.Tag = 'HeaderFileLbl';

  headerFile.Name = '';
  headerFile.RowSpan = [2 2];
  headerFile.ColSpan = [2 2];
  headerFile.Type = 'edit';
  headerFile.Tag = 'headerFile_tag';
  headerFile.ObjectProperty = 'HeaderFile';
  
  %-----------------------------------------------------------------------
  % Third Row contains:
  % - Description editarea widget
  %----------------------------------------------------------------------- 
  description.Name = DAStudio.message('Simulink:dialog:ObjectDescriptionPrompt');
  description.Type = 'editarea';
  description.RowSpan = [3 3];
  description.ColSpan = [1 2];
  description.Tag = 'description_tag';
  description.ObjectProperty = 'Description';  
  description.ListenToProperties = 'Elements';
  
  %-----------------------------------------------------------------------
  % Assemble main dialog struct
  %-----------------------------------------------------------------------  
  dlgstruct.DialogTitle = [class(h), ': ', name];
  
  if (DA_TABLE_SUPPORT)
    dlgstruct.Items = {elementsgrp, headerFileLbl, headerFile, description};
  else
    dlgstruct.Items = {elementsLbl, elementsVal, headerFileLbl, headerFile, description};
  end
  
  dlgstruct.LayoutGrid = [3 2];
  dlgstruct.HelpMethod = 'helpview';
  dlgstruct.HelpArgs   = {[docroot, '/mapfiles/simulink.map'], 'simulink_struct_type'};
  dlgstruct.RowStretch = [0 0 1];
  dlgstruct.ColStretch = [0 1];
