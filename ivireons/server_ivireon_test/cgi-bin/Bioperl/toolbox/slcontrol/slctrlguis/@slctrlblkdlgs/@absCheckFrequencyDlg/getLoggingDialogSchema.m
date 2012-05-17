function dlgStruct = getLoggingDialogSchema(this,~) 
 
% Author(s): A. Stothert 06-Oct-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/03/31 18:59:44 $

% GETLOGGINGDIALOGSCHEMA construct dialog widgets for logging
% properties

%Blank row at top of dialog
txtTopSpace.Type = 'text';
txtTopSpace.Tag  = 'txtTopSpace';
txtTopSpace.Name = ' ';
txtTopSpace.RowSpan = [1 1];
txtTopSpace.ColSpan = [2 2];

%Save data checkbox
chkSave.Type           = 'checkbox';
chkSave.Tag            = 'SaveToWorkspace';
chkSave.Name           = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtSaveToWorkspace');
chkSave.ObjectProperty = 'SaveToWorkspace';
chkSave.ObjectMethod   = 'callbackLogging';
chkSave.MethodArgs     = {'%tag','%dialog'};
chkSave.ArgDataTypes   = {'string','handle'};
chkSave.RowSpan        = [1 1];
chkSave.ColSpan        = [1 2];
%Save variable name text
txtSaveName.Type    = 'text';
txtSaveName.Tag     = 'txtSaveName';
txtSaveName.Buddy   = 'SaveName';
txtSaveName.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtSaveName');
txtSaveName.RowSpan = [2 2];
txtSaveName.ColSpan = [1 1];
%Save variable name edit box
edtSaveName.Type           = 'edit';
edtSaveName.Tag            = 'SaveName';
edtSaveName.Name           = '';
edtSaveName.ObjectProperty = 'SaveName';
edtSaveName.RowSpan        = [2 2];
edtSaveName.ColSpan        = [2 2];
edtSaveName.Enabled        = this.SaveToWorkspace;

%Place widgets in a panel
pnl.Type       = 'panel';
pnl.Items      = {chkSave, txtSaveName, edtSaveName};
pnl.LayoutGrid = [3 1];
pnl.RowStretch = [0 0 1];
pnl.ColStretch = [0 1];
pnl.RowSpan    = [2 2];
pnl.ColSpan    = [2 2];

%Create widgets to give left/right indents
txtLeftSpace.Type = 'text';
txtLeftSpace.Tag  = 'txtLeftSpace';
txtLeftSpace.Name = ' ';
txtLeftSpace.RowSpan = [1 3];
txtLeftSpace.ColSpan = [1 1];
txtRightSpace.Type = 'text';
txtRightSpace.Tag  = 'txtRightSpace';
txtRightSpace.Name = ' ';
txtRightSpace.RowSpan = [1 3];
txtRightSpace.ColSpan = [3 3];

%Create tab pane
dlgStruct.Name       = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:tabLogging');
dlgStruct.Items      = {txtLeftSpace, txtRightSpace, txtTopSpace, pnl};
dlgStruct.LayoutGrid = [3 3];
dlgStruct.RowStretch = [0 0 1];
dlgStruct.ColStretch = [0 1 0];
end