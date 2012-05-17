function dlgStruct = getViewDialogSchema(this,hBlk)  %#ok<INUSD>
 
% Author(s): A. Stothert 14-Oct-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:51:21 $

% GETVIEWDIALOGSCHEMA construct dialog widgets for view button and check box 
%

%View button
btnView.Type           = 'pushbutton';
btnView.Tag            = 'btnView';
btnView.Name           = DAStudio.message('SLControllib:checkpack:btnView');
btnView.ObjectMethod   = 'callbackView';
% btnView.MethodArgs     = {'%tag','%dialog'};
% btnView.ArgDataTypes   = {'string','handle'};
btnView.RowSpan        = [1 1];
btnView.ColSpan        = [1 1];
%View checkbox
chkView.Type           = 'checkbox';
chkView.Tag            = 'LaunchViewOnOpen';
chkView.Name           = DAStudio.message('SLControllib:checkpack:chkLaunchViewOnOpen');
chkView.ObjectProperty = 'LaunchViewOnOpen';
chkView.RowSpan        = [1 1];
chkView.ColSpan        = [2 2];

%View panel
dlgStruct.Type       = 'panel';
dlgStruct.Tag        = 'pnlView';
dlgStruct.Items      = {btnView, chkView};
dlgStruct.LayoutGrid = [1 3];
dlgStruct.ColStretch = [0 0 1];
end
