function dlgStruct = getBoundsDialogSchema(this,hBlk)  %#ok<INUSD>
 
% Author(s): A. Stothert 08-Oct-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/03/31 18:59:21 $

% GETBOUNDSDIALOGSCHEMA construct dialog widgets for bounds
% properties

%Blank row at top of dialog
txtTopSpace.Type = 'text';
txtTopSpace.Tag  = 'txtTopSpace';
txtTopSpace.Name = ' ';
txtTopSpace.RowSpan = [1 1];
txtTopSpace.ColSpan = [1 3];

%Step response check box
chkStep.Type           = 'checkbox';
chkStep.Tag            = 'EnableStepResponseBound';
chkStep.Name           = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtEnableStepResponseBound');
chkStep.ObjectProperty = 'EnableStepResponseBound';
chkStep.RowSpan        = [1 1];
chkStep.ColSpan        = [1 2];
%Final value text
txtFinalValue.Type    = 'text';
txtFinalValue.Tag     = 'txtFinalValue';
txtFinalValue.Buddy   = 'FinalValue';
txtFinalValue.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtLinStepFinalValue');
txtFinalValue.RowSpan = [2 2];
txtFinalValue.ColSpan = [1 1];
%Final value edit
edtFinalValue.Type           = 'edit';
edtFinalValue.Tag            = 'FinalValue';
edtFinalValue.Name           = '';
edtFinalValue.ObjectProperty = 'FinalValue';
edtFinalValue.RowSpan        = [2 2];
edtFinalValue.ColSpan        = [2 2];
%Rise time text
txtRiseTime.Type    = 'text';
txtRiseTime.Tag     = 'txtRiseTime';
txtRiseTime.Buddy   = 'RiseTime';
txtRiseTime.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtLinStepRiseTime');
txtRiseTime.RowSpan = [3 3];
txtRiseTime.ColSpan = [1 1];
%Rise time edit
edtRiseTime.Type           = 'edit';
edtRiseTime.Tag            = 'RiseTime';
edtRiseTime.Name           = '';
edtRiseTime.ObjectProperty = 'RiseTime';
edtRiseTime.RowSpan        = [3 3];
edtRiseTime.ColSpan        = [2 2];
%Percent Rise text
txtPercentRise.Type    = 'text';
txtPercentRise.Tag     = 'txtPercentRise';
txtPercentRise.Buddy   = 'PercentRise';
txtPercentRise.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtLinStepPercentRise');
txtPercentRise.RowSpan = [3 3];
txtPercentRise.ColSpan = [3 3];
%Percent Rise edit
edtPercentRise.Type           = 'edit';
edtPercentRise.Tag            = 'PercentRise';
edtPercentRise.Name           = '';
edtPercentRise.ObjectProperty = 'PercentRise';
edtPercentRise.RowSpan        = [3 3];
edtPercentRise.ColSpan        = [4 4];
%Settling time text
txtSettlingTime.Type    = 'text';
txtSettlingTime.Tag     = 'txtSettlingTime';
txtSettlingTime.Buddy   = 'SettlingTime';
txtSettlingTime.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtLinStepSettlingTime');
txtSettlingTime.RowSpan = [4 4];
txtSettlingTime.ColSpan = [1 1];
%Settling time edit
edtSettlingTime.Type           = 'edit';
edtSettlingTime.Tag            = 'SettlingTime';
edtSettlingTime.Name           = '';
edtSettlingTime.ObjectProperty = 'SettlingTime';
edtSettlingTime.RowSpan        = [4 4];
edtSettlingTime.ColSpan        = [2 2];
%Percent Settling text
txtPercentSettling.Type    = 'text';
txtPercentSettling.Tag     = 'txtPercentSettling';
txtPercentSettling.Buddy   = 'PercentSettling';
txtPercentSettling.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtLinStepPercentSettling');
txtPercentSettling.RowSpan = [4 4];
txtPercentSettling.ColSpan = [3 3];
%Percent Settling edit
edtPercentSettling.Type           = 'edit';
edtPercentSettling.Tag            = 'PercentSettling';
edtPercentSettling.Name           = '';
edtPercentSettling.ObjectProperty = 'PercentSettling';
edtPercentSettling.RowSpan        = [4 4];
edtPercentSettling.ColSpan        = [4 4];
%Percent Overshoot text
txtPercentOvershoot.Type    = 'text';
txtPercentOvershoot.Tag     = 'txtPercentOvershoot';
txtPercentOvershoot.Buddy   = 'PercentOvershoot';
txtPercentOvershoot.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtLinStepPercentOvershoot');
txtPercentOvershoot.RowSpan = [5 5];
txtPercentOvershoot.ColSpan = [1 1];
%Percent Overshoot edit
edtPercentOvershoot.Type           = 'edit';
edtPercentOvershoot.Tag            = 'PercentOvershoot';
edtPercentOvershoot.Name           = '';
edtPercentOvershoot.ObjectProperty = 'PercentOvershoot';
edtPercentOvershoot.RowSpan        = [5 5];
edtPercentOvershoot.ColSpan        = [2 2];
%Percent Undershoot text
txtPercentUndershoot.Type    = 'text';
txtPercentUndershoot.Tag     = 'txtPercentUndershoot';
txtPercentUndershoot.Buddy   = 'PercentUndershoot';
txtPercentUndershoot.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtLinStepPercentUndershoot');
txtPercentUndershoot.RowSpan = [5 5];
txtPercentUndershoot.ColSpan = [3 3];
%Percent Undershoot edit
edtPercentUndershoot.Type           = 'edit';
edtPercentUndershoot.Tag            = 'PercentUndershoot';
edtPercentUndershoot.Name           = '';
edtPercentUndershoot.ObjectProperty = 'PercentUndershoot';
edtPercentUndershoot.RowSpan        = [5 5];
edtPercentUndershoot.ColSpan        = [4 4];

%Magnitude bounds group
grpMagBounds.Type = 'panel';
grpMagBounds.Tag  = 'grpStepResponseBounds';
grpMagBounds.Items = {...
   chkStep, ...
   txtFinalValue, edtFinalValue, ...
   txtRiseTime, edtRiseTime, txtPercentRise, edtPercentRise, ...
   txtSettlingTime, edtSettlingTime, txtPercentSettling, edtPercentSettling, ...
   txtPercentOvershoot, edtPercentOvershoot, txtPercentUndershoot, edtPercentUndershoot};
grpMagBounds.LayoutGrid = [6 4];
grpMagBounds.RowStretch = [0 0 0 0 0 1];
grpMagBounds.ColStretch = [0 1 0 1];
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
