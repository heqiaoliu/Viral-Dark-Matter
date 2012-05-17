function shiftViewToBottom(dp)
% Set dialog panel shift to maximum (ie, reposition to bottom of display)

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:25 $

% Get parent panel height (same as dialog panel height)
% and total height of all dialogs when rendered (including gutters)
ppos = get(dp.hParent,'pos');
panel_dy = ppos(4);
dialogs_dy = dp.DialogsTotalHeight;

% Maximum allowable shift of dialogs in multi-dialog panel
max_shift = dialogs_dy-panel_dy;

dp.DialogShiftOverTop = max_shift; % vertical pixels past top of panel

% Mouse-drag dialog shift action
%  0 = move/rearrange one dialog
%  1 = shift all dialogs
%  2 = pos shift on dialog drag
%  3 = neg shift on dialog drag
dp.DialogShiftAction = 0;

% drawnow forces the slider bar to update itself properly
drawnow;
updateDialogPositions(dp);

