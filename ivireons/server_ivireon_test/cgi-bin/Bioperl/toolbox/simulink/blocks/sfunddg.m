function dlgStruct = sfunddg(source, h)

% Copyright 2003-2006 The MathWorks, Inc.
% $Revision: 1.1.6.8 $

% Top group is the block description
descTxt.Name            = h.BlockDescription;
descTxt.Type            = 'text';
descTxt.WordWrap        = true;

descGrp.Name            = h.BlockType;
descGrp.Type            = 'group';
descGrp.Items           = {descTxt};
descGrp.RowSpan         = [1 1];
descGrp.ColSpan         = [1 1];

% Bottom group is the block parameters
sfunName.Name           = 'S-function name:';
sfunName.Type           = 'edit';
sfunName.RowSpan        = [1 1];
sfunName.ColSpan        = [1 4];
sfunName.ObjectProperty = 'FunctionName';
sfunName.Tag            = sfunName.ObjectProperty;
sfunName.Enabled        = ~source.isHierarchySimulating;
% required for synchronization --------
sfunName.MatlabMethod   = 'slDialogUtil';
sfunName.MatlabArgs     = {source,'sync','%dialog','edit','%tag'};

sfunNameEdit.Name       = 'Edit';
sfunNameEdit.Type       = 'pushbutton';
sfunNameEdit.RowSpan    = [1 1];
sfunNameEdit.ColSpan    = [5 5];
sfunNameEdit.Tag        = 'EditButtonTag';
sfunNameEdit.Enabled    = ~source.isHierarchySimulating;
sfunNameEdit.MatlabMethod = 'sfunddg_cb';
sfunNameEdit.MatlabArgs = {'%dialog', '%source', '%tag'};

paramParams.Name        = 'S-function parameters:';
paramParams.Type        = 'edit';
paramParams.RowSpan     = [2 2];
paramParams.ColSpan     = [1 5];
paramParams.ObjectProperty = 'Parameters';
paramParams.Tag         = paramParams.ObjectProperty;
% required for synchronization --------
paramParams.MatlabMethod = 'slDialogUtil';
paramParams.MatlabArgs  = {source,'sync','%dialog','edit','%tag'};

moduleParams.Name        = 'S-function modules:';
moduleParams.Type        = 'edit';
moduleParams.RowSpan     = [3 3];
moduleParams.ColSpan     = [1 5];
moduleParams.ObjectProperty = 'SFunctionModules';
moduleParams.Tag         = moduleParams.ObjectProperty;
moduleParams.Enabled     = ~source.isHierarchySimulating; 
% required for synchronization --------
moduleParams.MatlabMethod = 'slDialogUtil';
moduleParams.MatlabArgs  = {source,'sync','%dialog','edit','%tag'};


spacer.Name    = '';
spacer.Type    = 'text';
spacer.RowSpan = [4 4];
spacer.ColSpan = [1 5];

paramGrp.Name  = 'Parameters';
paramGrp.Type  = 'group';
paramGrp.Items = {sfunName, sfunNameEdit, paramParams, moduleParams, spacer};

paramGrp.LayoutGrid = [4 5];
paramGrp.ColStretch = [1 1 1 1 0];
paramGrp.RowStretch = [0 0 0 1];
paramGrp.RowSpan    = [2 2];
paramGrp.ColSpan    = [1 1];
paramGrp.Source     = h;

%-----------------------------------------------------------------------
% Assemble main dialog struct
%-----------------------------------------------------------------------
dlgStruct.DialogTitle   = ['Block Parameters: ' strrep(h.Name, sprintf('\n'), ' ')];
dlgStruct.DialogTag     = 'S-Function';
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

[isLib, isLocked] = source.isLibraryBlock(h);
if isLocked
  dlgStruct.DisableDialog = 1;
else
  dlgStruct.DisableDialog = 0;
end

