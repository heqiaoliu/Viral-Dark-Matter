function resetDialogPanelShift(dp)
% Reset dialog panel shift to zero (ie, reposition to top of display)

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:40:12 $

dp.DialogShiftOverTop = 0; % vertical pixels past top of panel

% Mouse-drag dialog shift action
%  0 = move/rearrange one dialog
%  1 = shift all dialogs
%  2 = pos shift on dialog drag
%  3 = neg shift on dialog drag
dp.DialogShiftAction = 0;

updateDialogPositions(dp);

