function enableGUI(this, enabState)
%ENABLEGUI Enable the GUI when there is data.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/09/09 21:29:23 $

% If we do not have a visual, or if the visual we do have does have the
% axes field, or there are not valid objects to autoscale against, make
% sure that we are always disabled.
if isempty(this.Application.Visual) || ...
        ~isprop(this.Application.Visual, 'Axes')
    enabState = 'off';
end

hUI = this.Application.getGUI;

set(hUI.findchild('Base/Menus/Tools/ZoomAndAutoscale/Autoscale/PerformAutoscale'), 'Enable', enabState);
set(hUI.findchild('Base/Toolbars/Main/Tools/ZoomAndAutoscale/Autoscale'), 'Enable', enabState);

% [EOF]
