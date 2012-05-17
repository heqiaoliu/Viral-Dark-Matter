function dlgStruct = getViewDialogSchema(this,hBlk)  %#ok<INUSD>
%

% Author(s): A. Stothert 14-Oct-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/04/11 20:41:34 $

% GETVIEWDIALOGSCHEMA construct dialog widgets for view button and check
% box, overloaded from absCheckDlg as want to add plot type widgets
%


%Text for plot type
txtPlotType.Type    = 'text';
txtPlotType.Tag     = 'txtPlotType';
txtPlotType.Buddy   = 'PlotType';
txtPlotType.Name    = 'Plot type:';
txtPlotType.RowSpan = [1 1];
txtPlotType.ColSpan = [1 1];
%Combo box for plot type
cmbPlotType.Type = 'combobox';
cmbPlotType.Tag  = 'PlotType';
cmbPlotType.Entries = {...
   ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementBodePlot'), ...
   ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementNicholsPlot'), ...
   ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementNyquistPlot'), ...
   ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementTabularGPM')};
cmbPlotType.ObjectProperty = 'PlotType';
cmbPlotType.ObjectMethod   = 'callbackBounds';
cmbPlotType.MethodArgs     = {'%tag','%dialog'};
cmbPlotType.ArgDataTypes   = {'string','handle'};
cmbPlotType.RowSpan        = [1 1];
cmbPlotType.ColSpan        = [2 3];
%View button
btnView.Type           = 'pushbutton';
btnView.Tag            = 'btnView';
btnView.Name           = DAStudio.message('SLControllib:checkpack:btnView');
btnView.ObjectMethod   = 'showView';
btnView.MethodArgs     = {'%dialog'};
btnView.ArgDataTypes   = {'handle'};
btnView.RowSpan        = [2 2];
btnView.ColSpan        = [1 2];
%View checkbox
chkView.Type           = 'checkbox';
chkView.Tag            = 'LaunchViewOnOpen';
chkView.Name           = DAStudio.message('SLControllib:checkpack:chkLaunchViewOnOpen');
chkView.ObjectProperty = 'LaunchViewOnOpen';
chkView.RowSpan        = [2 2];
chkView.ColSpan        = [3 4];

%View panel
dlgStruct.Type       = 'panel';
dlgStruct.Tag        = 'pnlView';
dlgStruct.Items      = {txtPlotType, cmbPlotType, btnView, chkView};
dlgStruct.LayoutGrid = [2 5];
dlgStruct.RowStretch = [0 0];
dlgStruct.ColStretch = [0 0 0 0 1];
end