function varargout = render_zoommenus(hFig,position,flag)
%RENDER_ZOOMMENUS Render the Zoom In and Zoom Out menus.

%   Author(s): V. Pellissier
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.7.4.5 $  $Date: 2008/12/04 23:24:03 $ 

strs  = {xlate('Zoom In'),xlate('Zoom X'),xlate('Zoom Y'),xlate('Full View')};
cbs   = {@(h, ev) zoomState(h, 'on'), @(h, ev) zoomState(h, 'xon'), ...
    @(h, ev) zoomState(h, 'yon'), @(h, ev) defaultView(hFig)};
tags  = {'Exploration.ZoomIn','Exploration.ZoomX','Exploration.ZoomY','fullview'}; 

if nargin > 2 && strcmpi(flag, 'defaultview')
    strs = {strs{1:3}, xlate('Restore Default View'), strs{4}};
    tags = {tags{1:3}, 'defaultview', tags{4}};
    cbs{end+1} = @(h, ev) fullview(hFig);
end

% Add all the menus.
hzoommenus = addmenu(hFig,position,strs,cbs,tags);

% Set up the parent menu to update the Checked state of the submenu items
% before it is opened based on the state of the toggle buttons.
hMain = get(hzoommenus(1), 'Parent');
set(hMain, 'Callback', @(h, ev) updateZoomMenus(hFig));

if nargout>0,
    varargout{1} = hzoommenus;
end

% -------------------------------------------------------------------------
function zoomState(h, state)

if strcmp(get(h, 'Checked'), 'on')
    zoom('off')
else
    zoom(state);
end

% -------------------------------------------------------------------------
function updateZoomMenus(hFig)

set(findall(hFig, 'type', 'uimenu', 'Tag', 'Exploration.ZoomIn'), 'Checked', ...
    get(findall(hFig, 'type', 'uitoggletool', 'Tag', 'Exploration.ZoomIn'), 'state'));
set(findall(hFig, 'type', 'uimenu', 'Tag', 'Exploration.ZoomX'), 'Checked', ...
    get(findall(hFig, 'type', 'uitoggletool', 'Tag', 'Exploration.ZoomX'), 'state'));
set(findall(hFig, 'type', 'uimenu', 'Tag', 'Exploration.ZoomY'), 'Checked', ...
    get(findall(hFig, 'type', 'uitoggletool', 'Tag', 'Exploration.ZoomY'), 'state'));

% -------------------------------------------------------------------------
function defaultView(hFig)

hAxes = findall(hFig, 'type', 'axes');

for indx = 1:length(hAxes)
    if ~strcmpi(getappdata(hAxes(indx), 'zoomable'), 'off') && ...
            ~strcmpi(get(hAxes(indx), 'Tag'), 'legend') && ...
            ~strcmpi(get(hAxes(indx), 'Tag'), 'scribeOverlay')
        zoom(hAxes(indx), 'out')
    end
end

% -------------------------------------------------------------------------
function fullview(hFig)

hAxes = findobj(hFig, 'type', 'axes');

for indx = 1:length(hAxes)
    if ~strcmpi(getappdata(hAxes(indx), 'zoomable'), 'off')
        set(hAxes(indx), 'YLimMode', 'auto', 'XLimMode', 'auto');
    end
end

% [EOF]
