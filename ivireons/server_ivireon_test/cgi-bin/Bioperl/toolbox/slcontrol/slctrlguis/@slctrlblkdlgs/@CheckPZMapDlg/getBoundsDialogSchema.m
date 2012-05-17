function dlgStruct = getBoundsDialogSchema(this,hBlk)  %#ok<INUSD>
 
% Author(s): A. Stothert 08-Oct-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2010/04/21 22:05:07 $

% GETBOUNDSDIALOGSCHEMA construct dialog widgets for bounds
% properties

%Blank row at top of dialog
txtTopSpace.Type = 'text';
txtTopSpace.Tag  = 'txtTopSpace';
txtTopSpace.Name = ' ';
txtTopSpace.RowSpan = [1 1];
txtTopSpace.ColSpan = [2 2];

%Text 2nd order approx
txtApprox.Type = 'text';
txtApprox.Tag  = 'txtApprox';
txtApprox.Name = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:grpPZApproxBounds');
txtApprox.RowSpan = [1 1];
txtApprox.ColSpan = [1 4];
%Line gap.
txtMidSpace0.Type = 'text';
txtMidSpace0.Tag  = 'txtMidSpace0';
txtMidSpace0.Name = ' ';
txtMidSpace0.RowSpan = [2 2];
txtMidSpace0.ColSpan = [1 4];

%Settling time check box
chkSettling.Type           = 'checkbox';
chkSettling.Tag            = 'EnableSettlingTime';
chkSettling.Name           = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:chkEnableSettlingTime');
chkSettling.ObjectProperty = 'EnableSettlingTime';
chkSettling.ObjectMethod   = 'callbackBounds';
chkSettling.MethodArgs     = {'%tag','%dialog'};
chkSettling.ArgDataTypes   = {'string','handle'};
chkSettling.RowSpan        = [3 3];
chkSettling.ColSpan        = [2 4];
%Settling time text
txtSettling.Type    = 'text';
txtSettling.Tag     = 'txtSettling';
txtSettling.Buddy   = 'SettlingTime';
txtSettling.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtEnableSettlingTime');
txtSettling.RowSpan = [4 4];
txtSettling.ColSpan = [2 2];
%Settling time edit
edtSettling.Type           = 'edit';
edtSettling.Tag            = 'SettlingTime';
edtSettling.Name           = '';
edtSettling.ObjectProperty = 'Settling';
edtSettling.RowSpan        = [4 4];
edtSettling.ColSpan        = [3 4];
edtSettling.Enabled        = true;
%Line gap.
txtMidSpace1.Type = 'text';
txtMidSpace1.Tag  = 'txtMidSpace1';
txtMidSpace1.Name = ' ';
txtMidSpace1.RowSpan = [5 5];
txtMidSpace1.ColSpan = [1 4];

%Percent overshoot check box
chkOvershoot.Type           = 'checkbox';
chkOvershoot.Tag            = 'EnablePercentOvershoot';
chkOvershoot.Name           = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:chkEnablePercentOvershoot');
chkOvershoot.ObjectProperty = 'EnablePercentOvershoot';
chkOvershoot.ObjectMethod   = 'callbackBounds';
chkOvershoot.MethodArgs     = {'%tag','%dialog'};
chkOvershoot.ArgDataTypes   = {'string','handle'};
chkOvershoot.RowSpan        = [6 6];
chkOvershoot.ColSpan        = [2 4];
%Overshoot text
txtOvershoot.Type    = 'text';
txtOvershoot.Tag     = 'txtOvreshoot';
txtOvershoot.Buddy   = 'PercentOvershoot';
txtOvershoot.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtEnablePercentOvershoot');
txtOvershoot.RowSpan = [7 7];
txtOvershoot.ColSpan = [2 2];
%Percent overshoot edit
edtOvershoot.Type           = 'edit';
edtOvershoot.Tag            = 'PercentOvershoot';
edtOvershoot.Name           = '';
edtOvershoot.ObjectProperty = 'PercentOvershoot';
edtOvershoot.RowSpan        = [7 7];
edtOvershoot.ColSpan        = [3 4];
edtOvershoot.Enabled        = true;
%Line gap.
txtMidSpace2.Type = 'text';
txtMidSpace2.Tag  = 'txtMidSpace2';
txtMidSpace2.Name = ' ';
txtMidSpace2.RowSpan = [8 8];
txtMidSpace2.ColSpan = [1 4];

%Damping ratio check box
chkDampingratio.Type           = 'checkbox';
chkDampingratio.Tag            = 'EnableDampingRatio';
chkDampingratio.Name           = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:chkEnableDampingRatio');
chkDampingratio.ObjectProperty = 'EnableDampingRatio';
chkDampingratio.ObjectMethod   = 'callbackBounds';
chkDampingratio.MethodArgs     = {'%tag','%dialog'};
chkDampingratio.ArgDataTypes   = {'string','handle'};
chkDampingratio.RowSpan        = [9 9];
chkDampingratio.ColSpan        = [2 4];
%Damping ratio text
txtDampingratio.Type    = 'text';
txtDampingratio.Tag     = 'txtDampingratio';
txtDampingratio.Buddy   = 'DampingRatio';
txtDampingratio.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtEnableDampingRatio');
txtDampingratio.RowSpan = [10 10];
txtDampingratio.ColSpan = [2 2];
%Damping ratio edit
edtDampingratio.Type           = 'edit';
edtDampingratio.Tag            = 'DampingRatio';
edtDampingratio.Name           = '';
edtDampingratio.ObjectProperty = 'DampingRatio';
edtDampingratio.RowSpan        = [10 10];
edtDampingratio.ColSpan        = [3 4];
edtDampingratio.Enabled        = true;
%Line gap.
txtMidSpace3.Type = 'text';
txtMidSpace3.Tag  = 'txtMidSpace3';
txtMidSpace3.Name = ' ';
txtMidSpace3.RowSpan = [11 11];
txtMidSpace3.ColSpan = [1 4];

%Natural frequency check box
chkNatFreq.Type           = 'checkbox';
chkNatFreq.Tag            = 'EnableNaturalFrequency';
chkNatFreq.Name           = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:chkEnableNaturalFrequency');
chkNatFreq.ObjectProperty = 'EnableNaturalFrequency';
chkNatFreq.ObjectMethod   = 'callbackBounds';
chkNatFreq.MethodArgs     = {'%tag','%dialog'};
chkNatFreq.ArgDataTypes   = {'string','handle'};
chkNatFreq.RowSpan        = [12 12];
chkNatFreq.ColSpan        = [2 4];
%natural frequency text
txtNatFreq.Type    = 'text';
txtNatFreq.Tag     = 'txtNatFreq';
txtNatFreq.Buddy   = 'NaturalFrequency';
txtNatFreq.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtEnableNaturalFrequency',this.FrequencyUnits);
txtNatFreq.RowSpan = [13 13];
txtNatFreq.ColSpan = [2 2];
%Natural frequency combo-box
cmbNatFreq.Type           = 'combobox';
cmbNatFreq.Tag            = 'NaturalFrequencyBound';
cmbNatFreq.ObjectProperty = 'NaturalFrequencyBound';
cmbNatFreq.Entries        = {'>=', '<='};
cmbNatFreq.ObjectMethod   = 'callbackBounds';
cmbNatFreq.MethodArgs     = {'%tag','%dialog'};
cmbNatFreq.ArgDataTypes   = {'string','handle'};
cmbNatFreq.RowSpan        = [13 13];
cmbNatFreq.ColSpan        = [3 3];
%Natural frequency edit
edtNatFreq.Type           = 'edit';
edtNatFreq.Tag            = 'NaturalFrequency';
edtNatFreq.Name           = '';
edtNatFreq.ObjectProperty = 'NaturalFrequency';
edtNatFreq.RowSpan        = [13 13];
edtNatFreq.ColSpan        = [4 4];
edtNatFreq.Enabled        = true;

%Bounds group
grpBounds.Type = 'panel';
grpBounds.Tag  = 'grpBounds';
grpBounds.Items = {...
   txtApprox, ...
   txtMidSpace0, ...
   chkSettling, ...
   txtSettling, edtSettling, ...
   txtMidSpace1, ...
   chkOvershoot, ...
   txtOvershoot, edtOvershoot, ...
   txtMidSpace2, ...
   chkDampingratio, ...
   txtDampingratio, edtDampingratio, ...
   txtMidSpace3, ...
   chkNatFreq, ...
   txtNatFreq, cmbNatFreq, edtNatFreq};
grpBounds.LayoutGrid = [13 4];
grpBounds.RowSpan    = [2 2];
grpBounds.ColSpan    = [2 2];

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
dlgStruct.Name       = DAStudio.message('SLControllib:checkpack:tabBounds');
dlgStruct.Items      = {txtLeftSpace, txtRightSpace, txtTopSpace, grpBounds};
dlgStruct.LayoutGrid = [3 3];
dlgStruct.RowStretch = [0 0 1];
dlgStruct.ColStretch = [0 1 0];
end
