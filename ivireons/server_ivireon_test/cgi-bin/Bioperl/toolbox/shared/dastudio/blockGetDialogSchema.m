function dlgstruct = blockGetDialogSchema(h)
  
 % This is the default schema files for all SL blocks.
   slashn = double(sprintf('\n'));
   name = strrep(h.name, char(slashn), ' ');
   
   
  desc.Type = 'text';
  desc.Name = DAStudio.message('Simulink:dialog:MENoDialogsToDisplay');  
  desc.RowSpan = [1 1];
  desc.ColSpan = [1 1];
  
  paramlink.Name = [DAStudio.message('Simulink:dialog:MEOpenDialog', name)];
  paramlink.Type = 'hyperlink';
  paramlink.ToolTip = 'This is identical to double-clicking on the block in the model.';
  paramlink.MatlabMethod = 'open_system';
  paramlink.MatlabArgs = {h.getFullName};
  paramlink.RowSpan = [2 2];
  paramlink.ColSpan = [1 1];
  
  proplink.Name = [DAStudio.message('Simulink:dialog:MEOpenBlockProps', name) ];
  proplink.Type = 'hyperlink';
  proplink.ToolTip = 'Open block properties.';
  proplink.MatlabMethod = 'open_system';
  proplink.MatlabArgs = {h.getFullName, 'property'};
  proplink.RowSpan = [3 3];
  proplink.ColSpan = [1 1];
  
  spacer.Type = 'panel';
  spacer.RowSpan = [4 4];
  spacer.ColSpan = [1 1];
  
  dlgstruct.DialogTitle = [DAStudio.message('Simulink:dialog:MEBlockDialogTitle', name)];
  dlgstruct.Items = {desc, paramlink, proplink, spacer};
  dlgstruct.LayoutGrid = [4 1];
  dlgstruct.RowStretch = [0 0 0 1];
  
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/11/13 18:20:14 $
