function enableGUI(this, evn) %#ok
%ENABLEGUI enable or disable gui items

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2010/05/20 03:08:22 $

hApp = this.Application;
if isempty(hApp.DataSource) || ...
        isempty(hApp.DataSource.Controls) || ...
        ~shouldShowControls(hApp.DataSource, 'Base')
    vis = 'off';
else
    vis = 'on';
end

hUIMgr = this.Application.getGUI;
hMenu = hUIMgr.findchild('Menus','View','ViewBars','ShowPlaybackToolbar');
set(hMenu, 'Visible', vis);
propertyChanged(this, 'ShowPlaybackToolbar');

% [EOF]
