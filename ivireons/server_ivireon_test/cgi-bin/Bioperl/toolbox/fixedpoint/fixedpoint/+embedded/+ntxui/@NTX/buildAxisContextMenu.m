function buildAxisContextMenu(ntx)
% Context menu for the 'axis' object (background context menu)
% Fairly extensive, so it gets its own function
%
% It also needs to be called by other context menu builders
% when they are in a disabled state, so this had to be modular.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:20:53 $

dp = ntx.dp;

% Copy numerictype display string to system clipboard
hMainContext = dp.hContextMenu;
embedded.ntxui.createContextMenuItem(hMainContext, ...
    'Copy numerictype', @(h,e)copyNumericTypeToClipboard(ntx), ...
    'enable','on');

% Build the menus to change the units of the Y-Axis. Example: Percent,
% Count.
buildVerticalUnitsMenu(ntx,hMainContext);

% Build fraction text context menu
hp = uimenu('parent',hMainContext, ...
    'label','Fraction Units', ...
    'enable','on');
hm = [];
hm(1) = embedded.ntxui.createContextMenuItem(hp, ...
    'Fraction Length', @(hThis,e)changeDTXFracSpanText(ntx,hThis), ...
    'userdata',1);
hm(2) = embedded.ntxui.createContextMenuItem(hp, ...
    'Slope', @(hThis,e)changeDTXFracSpanText(ntx,hThis), ...
    'userdata',2);
set(hm(ntx.DTXFracSpanText),'checked','on');

% Add auto-hide menu, configure checkmark
autoHide = uiservices.logicalToOnOff(dp.AutoHide);
embedded.ntxui.createContextMenuItem(hMainContext,'Auto-hide Panel', ...
    @(h,e)toggleAutoHide(dp), ...
    'separator','on', 'checked',autoHide);
