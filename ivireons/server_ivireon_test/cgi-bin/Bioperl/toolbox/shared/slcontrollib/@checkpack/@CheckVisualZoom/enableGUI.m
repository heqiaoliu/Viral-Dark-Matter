function enableGUI(this, ~)
%ENABLEGUI Enable the GUI when there is data.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/05/10 17:38:06 $

% If we do not have a visual, or if the visual we do have does have the
% axes field, or there are not valid objects to autoscale against, make
% sure that we are always disabled.
if isempty(this.Application.Visual) 
   enabState = 'off';
else
   enabState = 'on';
end

hUI = this.Application.getGUI;

set(hUI.findchild('Base/Menus/Tools/ZoomAndAutoscale/Autoscale/PerformAutoscale'), 'Enable', enabState);
set(hUI.findchild('Base/Toolbars/Playback/ZoomAndAutoscale/Autoscale'), 'Enable', enabState);

% [EOF]
