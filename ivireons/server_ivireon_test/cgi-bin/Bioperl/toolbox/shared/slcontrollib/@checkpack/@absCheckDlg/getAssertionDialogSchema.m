function dlgStruct = getAssertionDialogSchema(this,hBlk) %#ok<INUSD>
 
% Author(s): A. Stothert 06-Oct-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/03/31 18:38:24 $

% GETDIALOGASSERTIONSCHEMA construct dialog widgets for assertion
% properties
%

%Blank row at top of dialog
txtTopSpace.Type = 'text';
txtTopSpace.Tag  = 'txtTopSpace';
txtTopSpace.Name = ' ';
txtTopSpace.RowSpan = [1 1];
txtTopSpace.ColSpan = [2 2];

%Enable assertion checkbox
chkEnable.Type           = 'checkbox';
chkEnable.Tag            = 'enabled';
chkEnable.Name           = DAStudio.message('SLControllib:checkpack:chkEnableAssertion');
chkEnable.ObjectProperty = 'enabled';
chkEnable.ObjectMethod   = 'callbackAssertion';
chkEnable.MethodArgs     = {'%tag','%dialog'};
chkEnable.ArgDataTypes   = {'string','handle'};
chkEnable.RowSpan        = [1 1];
chkEnable.ColSpan        = [1 1];
%Assertion callback text
txtCallback.Type    = 'text';
txtCallback.Tag     = 'txtCallback';
txtCallback.Buddy   = 'callback';
txtCallback.Name    = DAStudio.message('SLControllib:checkpack:txtAssertionCallback');
txtCallback.RowSpan = [2 2];
txtCallback.ColSpan = [1 1];
%Assertion callback edit box
edtCallback.Type           = 'edit';
edtCallback.Tag            = 'callback';
edtCallback.Name           = '';
edtCallback.ObjectProperty = 'callback';
edtCallback.RowSpan        = [3 3];
edtCallback.ColSpan        = [1 1];
edtCallback.Enabled        = this.enabled;
%Stop simulation checkbox
chkStop.Type           = 'checkbox';
chkStop.Tag            = 'stopWhenAssertionFail';
chkStop.Name           = DAStudio.message('SLControllib:checkpack:chkStopWhenAssertionFail');
chkStop.ObjectProperty = 'stopWhenAssertionFail';
chkStop.RowSpan        = [4 4];
chkStop.ColSpan        = [1 1];
chkStop.Enabled        = this.enabled;
%Output assertion signal checkbox
chkExport.Type           = 'checkbox';
chkExport.Tag            = 'export';
chkExport.Name           = DAStudio.message('SLControllib:checkpack:chkExportAssertion');
chkExport.ObjectProperty = 'export';
chkExport.RowSpan        = [5 5];
chkExport.ColSpan        = [1 1];

%Place widgets in a panel
pnl.Type  = 'panel';
pnl.Items = {chkEnable, txtCallback, edtCallback, ...
   chkStop, chkExport};
pnl.LayoutGrid = [6 1];
pnl.RowStretch = [zeros(1,5) 1];
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
dlgStruct.Name       = DAStudio.message('SLControllib:checkpack:tabAssertion');
dlgStruct.Items      = {txtLeftSpace, txtRightSpace, txtTopSpace, pnl};
dlgStruct.LayoutGrid = [3 1];
dlgStruct.RowStretch = [0 0 1];
dlgStruct.ColStretch = [0 1 0];
end