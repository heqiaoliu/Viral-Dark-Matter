function buildVerticalUnitsMenu(ntx, hParentMenu)
% BUILDVERTICALUNITSMENU Builds menu items to change the vertical units of
% the Y-Axis in the Histogram plot. This method is used by both
% HistogramVisual.createNTXMenus() and buildAxisContextMenu() methods to
% add these menu items to the main menu and context menu. hParentMenu can
% either be a context menu handle or a handle to a main menu.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:21:35 $

if isa(handle(hParentMenu), 'uicontextmenu')
    % Histogram units (Y-axis)
    hParentMenu = uimenu('parent',hParentMenu, ...
        'separator','on', ...
        'label','Vertical Units',...
        'tag','VerticalUnitsMenu');
end

hm = [];
hm(1) = embedded.ntxui.createContextMenuItem(hParentMenu, ...
    'Percent (%)', @(hThis,e)changeVerticalUnitsOption(ntx,hThis), ...
    'userdata',1, 'tag','PercentMenu');
hm(2) = embedded.ntxui.createContextMenuItem(hParentMenu, ...
    'Count', @(hThis,e)changeVerticalUnitsOption(ntx,hThis), ...
    'userdata',2,'tag','CountMenu');
set(hm(ntx.HistVerticalUnits),'checked','on');


% [EOF]
