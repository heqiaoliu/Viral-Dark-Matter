function setPanelViewFraction(dp,frac)
% Set dialog panel view position to a fraction between top and bottom
% Set frac=0 to set the view to the top of the panel, and frac=1 to set the
% view to the bottom of the panel.
%
% This does NOT change the scroll bar position
% It is assumed that the scroll bar was either moved beforehand and this is
% in response to that motion, or that the caller will update the scroll bar
% afterward.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:22 $

% Clamp to range [0,1]
frac = min(1,max(0,frac));

% Get parent panel height (same as dialog panel height),
% and the total vertical space occupied by individual dialogs
% (including vertical gutters, etc).  These are all precomputed by
% setDialogVerticalExtents()

% Visible space provided for display of dialog panels
ppos = get(dp.hParent,'pos');
panel_dy = ppos(4);

% Total vertical space needed if all dialogs were visible
% Includes vertical gutter space.
% Could be less than or greater than panel_dy
dialogs_dy = dp.DialogsTotalHeight;

% Determine maximum pixel shift of dialogs within panel
%  maxShift > 0: dialogs take more vert space than panel provides
%     (that is, dialogs can shift above the visible panel area)
%  maxShift <= 0: dialogs don't take more vert space than panel
%      (that is, dialogs cannot shift above visible panel area)
maxShift = dialogs_dy - panel_dy;

% Compute new pixel shift of all dialogs within panel based on desired
% fractional shift from slider
if maxShift <= 0
    % Dialogs take less vertical space than panel provides
    % There's never a need to shift the dialogs in this case.
    shift = 0;
else
    shift = floor(frac * maxShift);
end
dp.DialogShiftOverTop = shift;

% Display new dialog shift
updateDialogPositions(dp);

