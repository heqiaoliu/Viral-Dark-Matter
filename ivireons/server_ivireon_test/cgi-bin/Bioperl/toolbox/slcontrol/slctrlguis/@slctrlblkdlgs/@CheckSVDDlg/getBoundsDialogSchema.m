function dlgStruct = getBoundsDialogSchema(this,hBlk)  %#ok<INUSD>
 
% Author(s): A. Stothert 08-Oct-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2010/04/11 20:41:46 $

% GETBOUNDSDIALOGSCHEMA construct dialog widgets for bounds
% properties

%Blank row at top of dialog
txtTopSpace.Type = 'text';
txtTopSpace.Tag  = 'txtTopSpace';
txtTopSpace.Name = ' ';
txtTopSpace.RowSpan = [1 1];
txtTopSpace.ColSpan = [1 3];

%Upper bound check box
chkUpper.Type           = 'checkbox';
chkUpper.Tag            = 'EnableUpperBound';
chkUpper.Name           = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtEnableUpperSigmaBound');
chkUpper.ObjectProperty = 'EnableUpperBound';
chkUpper.ObjectMethod   = 'callbackBounds';
chkUpper.MethodArgs     = {'%tag','%dialog'};
chkUpper.ArgDataTypes   = {'string','handle'};
chkUpper.RowSpan        = [1 1];
chkUpper.ColSpan        = [1 2];
%Upper frequencies text
txtUpperFreq.Type    = 'text';
txtUpperFreq.Tag     = 'txtUpperFreq';
txtUpperFreq.Buddy   = 'UpperBoundFrequencies';
txtUpperFreq.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtFrequencies',this.FrequencyUnits);
txtUpperFreq.RowSpan = [2 2];
txtUpperFreq.ColSpan = [1 1];
%Upper magnitudes edit
edtUpperFreq.Type           = 'edit';
edtUpperFreq.Tag            = 'UpperBoundFrequencies';
edtUpperFreq.Name           = '';
edtUpperFreq.ObjectProperty = 'UpperBoundFrequencies';
edtUpperFreq.RowSpan        = [2 2];
edtUpperFreq.ColSpan        = [2 2];
edtUpperFreq.Enabled        = true;
%Upper magnitudes text
txtUpperMag.Type    = 'text';
txtUpperMag.Tag     = 'txtUpperMag';
txtUpperMag.Buddy   = 'UpperBoundMagnitudes';
txtUpperMag.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtMagnitudes',this.MagnitudeUnits);
txtUpperMag.RowSpan = [3 3];
txtUpperMag.ColSpan = [1 1];
%Upper magnitudes edit
edtUpperMag.Type           = 'edit';
edtUpperMag.Tag            = 'UpperBoundMagnitudes';
edtUpperMag.Name           = '';
edtUpperMag.ObjectProperty = 'UpperBoundMagnitudes';
edtUpperMag.RowSpan        = [3 3];
edtUpperMag.ColSpan        = [2 2];
edtUpperMag.Enabled        = true;

%Dummy text to separate upper and lower bounds
txtMidSpace.Type    = 'text';
txtMidSpace.Tag     = 'txtMidSpace';
txtMidSpace.Name    = ' ';
txtMidSpace.RowSpan = [4 4];
txtMidSpace.ColSpan = [1 2];

%Lower bound check box
chkLower.Type           = 'checkbox';
chkLower.Tag            = 'EnableLowerBound';
chkLower.Name           = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtEnableLowerSigmaBound');
chkLower.ObjectProperty = 'EnableLowerBound';
chkLower.ObjectMethod   = 'callbackBounds';
chkLower.MethodArgs     = {'%tag','%dialog'};
chkLower.ArgDataTypes   = {'string','handle'};
chkLower.RowSpan        = [5 5];
chkLower.ColSpan        = [1 2];
%Lower frequencies text
txtLowerFreq.Type    = 'text';
txtLowerFreq.Tag     = 'txtLowerFreq';
txtLowerFreq.Buddy   = 'LowerBoundFrequencies';
txtLowerFreq.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtFrequencies',this.FrequencyUnits);
txtLowerFreq.RowSpan = [6 6];
txtLowerFreq.ColSpan = [1 1];
%Lower magnitudes edit
edtLowerFreq.Type           = 'edit';
edtLowerFreq.Tag            = 'LowerBoundFrequencies';
edtLowerFreq.Name           = '';
edtLowerFreq.ObjectProperty = 'LowerBoundFrequencies';
edtLowerFreq.RowSpan        = [6 6];
edtLowerFreq.ColSpan        = [2 2];
edtLowerFreq.Enabled        = true;
%Lower magnitudes text
txtLowerMag.Type    = 'text';
txtLowerMag.Tag     = 'txtLowerMag';
txtLowerMag.Buddy   = 'LowerBoundMagnitudes';
txtLowerMag.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtMagnitudes',this.MagnitudeUnits);
txtLowerMag.RowSpan = [7 7];
txtLowerMag.ColSpan = [1 1];
%Lower magnitudes edit
edtLowerMag.Type           = 'edit';
edtLowerMag.Tag            = 'LowerBoundMagnitudes';
edtLowerMag.Name           = '';
edtLowerMag.ObjectProperty = 'LowerBoundMagnitudes';
edtLowerMag.RowSpan        = [7 7];
edtLowerMag.ColSpan        = [2 2];
edtLowerMag.Enabled        = true;

%Magnitude bounds group
grpMagBounds.Type = 'panel';
grpMagBounds.Tag  = 'grpMagBounds';
grpMagBounds.Items = {...
   chkUpper, ...
   txtUpperFreq, edtUpperFreq, ...
   txtUpperMag, edtUpperMag, ...
   txtMidSpace, ...
   chkLower, ...
   txtLowerFreq, edtLowerFreq, ...
   txtLowerMag, edtLowerMag};
grpMagBounds.LayoutGrid = [7 2];
grpMagBounds.RowSpan    = [2 2];
grpMagBounds.ColSpan    = [2 2];

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
dlgStruct.Items      = {txtLeftSpace, txtTopSpace, txtRightSpace, grpMagBounds};
dlgStruct.LayoutGrid = [3 3];
dlgStruct.RowStretch = [0 0 1];
dlgStruct.ColStretch = [0 1 0];
end
