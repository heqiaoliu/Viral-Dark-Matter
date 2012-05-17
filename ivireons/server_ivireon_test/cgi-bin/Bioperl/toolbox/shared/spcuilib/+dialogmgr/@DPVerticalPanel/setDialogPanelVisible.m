function setDialogPanelVisible(dp,vis)
% Change visibility of dialog panel
% Kick auto-hide watchdog timer

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:19 $

% Change dialog visibility
dp.PanelVisible = vis;
showDialogPanel(dp); % Change the visualizer display state
updateSplitterBarAction(dp);

% If DialogPanel is becoming visible, and AutoHide is active, kick the
% watchdog timer.  This alerts the system to auto-hide after the next
% time-out period, only if auto-hide is turned on.
if vis && dp.AutoHide
    autoHideTimerReset(dp);
end
