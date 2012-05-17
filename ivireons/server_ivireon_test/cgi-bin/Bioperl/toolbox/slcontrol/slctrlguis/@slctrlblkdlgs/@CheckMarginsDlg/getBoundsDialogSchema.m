function dlgStruct = getBoundsDialogSchema(this,hBlk)  %#ok<INUSD>
 
% Author(s): A. Stothert 08-Oct-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2010/04/30 00:44:04 $

% GETBOUNDSDIALOGSCHEMA construct dialog widgets for bounds
% properties

%Blank row at top of dialog
txtTopSpace.Type = 'text';
txtTopSpace.Tag  = 'txtTopSpace';
txtTopSpace.Name = ' ';
txtTopSpace.RowSpan = [1 1];
txtTopSpace.ColSpan = [1 3];

%Margins check box
chkGM.Type           = 'checkbox';
chkGM.Tag            = 'EnableMargins';
chkGM.Name           = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:chkEnableMargins');
chkGM.ObjectProperty = 'EnableMargins';
chkGM.ObjectMethod   = 'callbackBounds';
chkGM.MethodArgs     = {'%tag','%dialog'};
chkGM.ArgDataTypes   = {'string','handle'};
chkGM.RowSpan        = [1 1];
chkGM.ColSpan        = [1 3];
%Gain margin text 
txtGM.Type    = 'text';
txtGM.Tag     = 'txtGainMargin';
txtGM.Buddy   = 'GainMargin';
txtGM.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtGainMargin',this.MagnitudeUnits);
txtGM.RowSpan = [2 2];
txtGM.ColSpan = [1 1];
%Gain margin edit
edtGM.Type           = 'edit';
edtGM.Tag            = 'GainMargin';
edtGM.Name           = '';
edtGM.ObjectProperty = 'GainMargin';
edtGM.RowSpan        = [2 2];
edtGM.ColSpan        = [2 3];
edtGM.Enabled        = true;
%Phase margin text
txtPM.Type    = 'text';
txtPM.Tag     = 'txtPhaseMargin';
txtPM.Buddy   = 'PhaseMargin';
txtPM.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtPhaseMargin',this.PhaseUnits);
txtPM.RowSpan = [3 3];
txtPM.ColSpan = [1 1];
%Phase margin edit
edtPM.Type           = 'edit';
edtPM.Tag            = 'PhaseMargin';
edtPM.Name           = '';
edtPM.ObjectProperty = 'PhaseMargin';
edtPM.RowSpan        = [3 3];
edtPM.ColSpan        = [2 3];
edtPM.Enabled        = true;
%Space 
txtMidSpace.Type    = 'text';
txtMidSpace.Tag     = 'txtMidSpace';
txtMidSpace.Name    = ' ';
txtMidSpace.RowSpan = [4 4];
txtMidSpace.ColSpan = [2 3];
%Feedback sign text
txtFeedbackSign.Type    = 'text';
txtFeedbackSign.Tag     = 'txtFeedbackSign';
txtFeedbackSign.Buddy   = 'FeedbackSign';
txtFeedbackSign.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtFeedbackSign');
txtFeedbackSign.RowSpan = [5 5];
txtFeedbackSign.ColSpan = [1 1];
%Feedback sign combobox 
cmbFeedbackSign.Type           = 'combobox';
cmbFeedbackSign.Tag            = 'FeedbackSign';
cmbFeedbackSign.ObjectProperty = 'FeedbackSign';
cmbFeedbackSign.Entries        = {...
   ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementFeedbackSignNeg'),...
   ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementFeedbackSignPos')};
cmbFeedbackSign.ObjectMethod   = 'callbackBounds';
cmbFeedbackSign.MethodArgs     = {'%tag','%dialog'};
cmbFeedbackSign.ArgDataTypes   = {'string','handle'};
cmbFeedbackSign.RowSpan        = [5 5];
cmbFeedbackSign.ColSpan        = [2 2];
%Margins group
grpMargins.Type  = 'panel';
grpMargins.Tag   = 'grpBounds';
grpMargins.Items = {...
   chkGM, ...
   txtGM, edtGM, ...
   txtPM, edtPM, ...
   txtMidSpace, ...
   txtFeedbackSign, cmbFeedbackSign};
grpMargins.LayoutGrid = [5 3];
grpMargins.ColStretch = [0 0 1];
grpMargins.RowSpan    = [2 2];
grpMargins.ColSpan    = [2 2];

%Create widgets to give left/right indents
txtLeftSpace.Type     = 'text';
txtLeftSpace.Tag      = 'txtLeftSpace';
txtLeftSpace.Name     = ' ';
txtLeftSpace.RowSpan  = [1 2];
txtLeftSpace.ColSpan  = [1 1];
txtRightSpace.Type    = 'text';
txtRightSpace.Tag     = 'txtRightSpace';
txtRightSpace.Name    = ' ';
txtRightSpace.RowSpan = [1 2];
txtRightSpace.ColSpan = [3 3];

%Create tab pane
dlgStruct.Name       = DAStudio.message('SLControllib:checkpack:tabBounds');
dlgStruct.Items      = {txtLeftSpace, txtTopSpace, txtRightSpace, grpMargins};
dlgStruct.LayoutGrid = [3 3];
dlgStruct.RowStretch = [0 0 1];
dlgStruct.ColStretch = [0 1 0];
end