function react(this)
%REACT React to current zoom state

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/31 18:41:45 $

% Install cursor and functions
hmgr = getGUI(this.Application);
hFig = get(this.Application,'Parent');

hZoomIn  = hmgr.findchild('Base/Menus/Tools/ZoomAndAutoscale/Zoom/ZoomIn');
hZoomX = hmgr.findchild('Base/Menus/Tools/ZoomAndAutoscale/Zoom/ZoomX');
hZoomY = hmgr.findchild('Base/Menus/Tools/ZoomAndAutoscale/Zoom/ZoomY');

set(get(hZoomIn, 'WidgetHandle'), 'Checked', 'Off');
set(get(hZoomX,  'WidgetHandle'), 'Checked', 'Off');
set(get(hZoomY,  'WidgetHandle'), 'Checked', 'Off');

switch lower(this.ZoomMode)
    case 'zoomin'
        set(get(hZoomIn, 'WidgetHandle'), 'Checked', 'On');
    case 'zoomx'
        set(get(hZoomX, 'WidgetHandle'), 'Checked', 'On');
    case 'zoomy'
        set(get(hZoomY, 'WidgetHandle'), 'Checked', 'On');
    otherwise
        zoom(hFig,'off');
end

% if the DataSource or UIMgr is empty or the AppliedZoom matches the new
% zoom, just toggle the setting without calling zoom.
source = this.Application.DataSource;
if isempty(source) || isDataEmpty(source) || ...
        isempty(hmgr) || strcmp(this.AppliedZoomMode, this.ZoomMode)
    return;
end

this.AppliedZoomMode = this.ZoomMode;
switch lower(this.ZoomMode)
    case 'zoomin'
        % zoom-in mode
        zoom(hFig, 'on');
        
    case 'zoomx'
        % zoom-out mode
        zoom(hFig, 'xon');

    case 'zoomy'
        % zoom-out mode
        zoom(hFig, 'yon');
    
    otherwise
        zoom(hFig, 'off');
end

% [EOF]
