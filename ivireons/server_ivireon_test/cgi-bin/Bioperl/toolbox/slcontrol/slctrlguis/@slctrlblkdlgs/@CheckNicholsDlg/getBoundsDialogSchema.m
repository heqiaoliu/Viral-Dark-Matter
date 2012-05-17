function dlgStruct = getBoundsDialogSchema(this,hBlk)  %#ok<INUSD>
 
% Author(s): A. Stothert 08-Oct-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2010/04/30 00:44:09 $

% GETBOUNDSDIALOGSCHEMA construct dialog widgets for bounds
% properties

%Blank row at top of dialog
txtSpace0.Type = 'text';
txtSpace0.Tag  = 'txtSpace0';
txtSpace0.Name = ' ';
txtSpace0.RowSpan = [1 1];
txtSpace0.ColSpan = [1 3];

%Margins check box
chkGM.Type           = 'checkbox';
chkGM.Tag            = 'EnableMargins';
chkGM.Name           = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:chkEnableMargins');
chkGM.ObjectProperty = 'EnableMargins';
chkGM.ObjectMethod   = 'callbackBounds';
chkGM.MethodArgs     = {'%tag','%dialog'};
chkGM.ArgDataTypes   = {'string','handle'};
chkGM.RowSpan        = [1 1];
chkGM.ColSpan        = [1 2];
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
edtGM.ColSpan        = [2 2];
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
edtPM.ColSpan        = [2 2];
edtPM.Enabled        = true;
%Margins group
grpMargins.Type = 'panel';
grpMargins.Tag  = 'grpBounds';
grpMargins.Items = {...
   chkGM, ...
   txtGM, edtGM, ...
   txtPM, edtPM};
grpMargins.LayoutGrid = [3 2];
grpMargins.RowSpan    = [2 2];
grpMargins.ColSpan    = [2 2];

%Space after margins
txtSpace1      = txtSpace0;
txtSpace1.Tag  = 'txtSpace1';
txtSpace1.RowSpan = [3 3];
txtSpace1.ColSpan = [2 2];

%CL peak gain check box
chkPeakGain.Type           = 'checkbox';
chkPeakGain.Tag            = 'EnableCLPeakGain';
chkPeakGain.Name           = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:chkEnableCLPeakGain');
chkPeakGain.ObjectProperty = 'EnableCLPeakGain';
chkPeakGain.ObjectMethod   = 'callbackBounds';
chkPeakGain.MethodArgs     = {'%tag','%dialog'};
chkPeakGain.ArgDataTypes   = {'string','handle'};
chkPeakGain.RowSpan        = [1 1];
chkPeakGain.ColSpan        = [1 2];
%CL peak text
txtPeakGain.Type    = 'text';
txtPeakGain.Tag     = 'txtPeakGain';
txtPeakGain.Buddy   = 'CLPeakGain';
txtPeakGain.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtEnableCLPeakGain',this.MagnitudeUnits);
txtPeakGain.RowSpan = [2 2];
txtPeakGain.ColSpan = [1 1];
%CL peak gain edit
edtPeakGain.Type           = 'edit';
edtPeakGain.Tag            = 'CLPeakGain';
edtPeakGain.Name           = '';
edtPeakGain.ObjectProperty = 'CLPeakGain';
edtPeakGain.RowSpan        = [2 2];
edtPeakGain.ColSpan        = [2 2];
edtPeakGain.Enabled        = true;
%Peak gain group
grpCLPeak.Type = 'panel';
grpCLPeak.Tag  = 'grpBounds';
grpCLPeak.Items = {...
   chkPeakGain, ...
   txtPeakGain, edtPeakGain};
grpCLPeak.LayoutGrid = [2 2];
grpCLPeak.RowStretch = [0 0];
grpCLPeak.ColStretch = [0 1];
grpCLPeak.RowSpan    = [4 4];
grpCLPeak.ColSpan    = [2 2];

%Space after CLPeak
txtSpace2         = txtSpace0;
txtSpace2.Tag     = 'txtSpace2';
txtSpace2.RowSpan = [5 5];
txtSpace2.ColSpan = [2 2];

%Gain-phase bound checkbox
chkGainPhase.Type           = 'checkbox';
chkGainPhase.Tag            = 'EnableGainPhaseBound';
chkGainPhase.Name           = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtEnableGainPhaseBound');
chkGainPhase.ObjectProperty = 'EnableGainPhaseBound';
chkGainPhase.ObjectMethod   = 'callbackBounds';
chkGainPhase.MethodArgs     = {'%tag','%dialog'};
chkGainPhase.ArgDataTypes   = {'string','handle'};
chkGainPhase.RowSpan        = [1 1];
chkGainPhase.ColSpan        = [1 2];
%OpenLoop phases text
txtOLPhases.Type    = 'text';
txtOLPhases.Tag     = 'txtOLPhases';
txtOLPhases.Buddy   = 'OLPhases';
txtOLPhases.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtOLPhases',this.PhaseUnits);
txtOLPhases.RowSpan = [2 2];
txtOLPhases.ColSpan = [1 1];
%OpenLoop phases edit
edtOLPhases.Type           = 'edit';
edtOLPhases.Tag            = 'OLPhases';
edtOLPhases.Name           = '';
edtOLPhases.ObjectProperty = 'OLPhases';
edtOLPhases.RowSpan        = [2 2];
edtOLPhases.ColSpan        = [2 2];
edtOLPhases.Enabled        = true;
%OpenLoop phases text
txtOLGains.Type    = 'text';
txtOLGains.Tag     = 'txtOLGains';
txtOLGains.Buddy   = 'OLGains';
txtOLGains.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtOLGains',this.MagnitudeUnits);
txtOLGains.RowSpan = [3 3];
txtOLGains.ColSpan = [1 1];
%OpenLoop phases edit
edtOLGains.Type           = 'edit';
edtOLGains.Tag            = 'OLGains';
edtOLGains.Name           = '';
edtOLGains.ObjectProperty = 'OLGains';
edtOLGains.RowSpan        = [3 3];
edtOLGains.ColSpan        = [2 2];
edtOLGains.Enabled        = true;
%GMP group
grpGPM.Type = 'panel';
grpGPM.Tag  = 'grpGPM';
grpGPM.Items = {...
   chkGainPhase, ...
   txtOLPhases, edtOLPhases, ...
   txtOLGains, edtOLGains};
grpGPM.LayoutGrid = [3 2];
grpGPM.RowSpan    = [6 6];
grpGPM.ColSpan    = [2 2];

%Space after CL-Gain/Phase
txtSpace3         = txtSpace0;
txtSpace3.Tag     = 'txtSpace3';
txtSpace3.RowSpan = [7 7];
txtSpace3.ColSpan = [2 2];

%Feedback sign text
txtFeedbackSign.Type    = 'text';
txtFeedbackSign.Tag     = 'txtFeedbackSign';
txtFeedbackSign.Buddy   = 'FeedbackSign';
txtFeedbackSign.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtFeedbackSign');
txtFeedbackSign.RowSpan = [1 1];
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
cmbFeedbackSign.RowSpan        = [1 1];
cmbFeedbackSign.ColSpan        = [2 2];
%Feedback sign group
grpFeedbackSign.Type = 'panel';
grpFeedbackSign.Tag  = 'grpFeedbackSign';
grpFeedbackSign.Items = {...
   txtFeedbackSign, cmbFeedbackSign};
grpFeedbackSign.LayoutGrid = [1 3];
grpFeedbackSign.ColStretch = [0 0 1];
grpFeedbackSign.RowSpan    = [8 8];
grpFeedbackSign.ColSpan    = [2 2];

%Create widgets to give left/right indents
txtLeftSpace.Type = 'text';
txtLeftSpace.Tag  = 'txtLeftSpace';
txtLeftSpace.Name = ' ';
txtLeftSpace.RowSpan = [1 8];
txtLeftSpace.ColSpan = [1 1];
txtRightSpace.Type = 'text';
txtRightSpace.Tag  = 'txtRightSpace';
txtRightSpace.Name = ' ';
txtRightSpace.RowSpan = [1 8];
txtRightSpace.ColSpan = [3 3];

%Create tab pane
dlgStruct.Name       = DAStudio.message('SLControllib:checkpack:tabBounds');
dlgStruct.Items      = {...
   txtLeftSpace, txtSpace0, txtRightSpace, ...
   grpMargins, txtSpace1, grpCLPeak, ...
   txtSpace2, grpGPM, ...
   txtSpace3,grpFeedbackSign};
dlgStruct.LayoutGrid = [9 3];
dlgStruct.RowStretch = [0 0 0 0 0 0 0 0 1];
dlgStruct.ColStretch = [0 1 0];
end
