function hmenus = createNTXMenus(this)
%CREATENTXMENUS Adds menus for the NTX UI to the Framework

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:41:27 $


% Create Dialog Panel Menu
mDialogPanelMenu = uimgr.uimenugroup('DialogPanelMenu',1, 'Dialog Panel');
% Add a dummy child menu so that the main menu is rendered in the
% Framework. If a menu group has no children, uimgr does not render it. 
mchild = uimgr.uimenu('Dummy Child','<empty sub-menu>');
mDialogPanelMenu.add(mchild);

% Add a callback to the View menu in the Framework in order to add menus
% dynamically.
hMgr = this.Application.UIMgr;
viewMenu = hMgr.findchild('Menus','View');
viewMenu.WidgetProperties = {'callback',...
    @(hco, ev) locCreateDynamicMenus(this)};

% Add a Frequency scale menu item
mFreqMenu = uimgr.uimenugroup('VerticalUnits',3,'Vertical Units');
% Add a dummy child menu so that the main menu is rendered in the
% Framework. If a menu group has no children, uimgr does not render it. 
mchild = uimgr.uimenu('Dummy Child','<empty sub-menu>');
mFreqMenu.add(mchild);

hmenus =  {mDialogPanelMenu, 'Base/Menus/View';...
    mFreqMenu, 'Base/Menus/View'};

% There are a few things that need to be refactored in the future. 
% 1) The context menus need to be integrated with uimgr (G550936).
% 2) Once the context menus are integrated, dialogmgr can leverage the
%    system and add uimgr.contextmenus.
% 3) In-order to create the children of Dialog Panel & Vertical Units menu
%    groups, we had to add a callback to the View menu owned by the
%    framework. This is not the right design. However there isn't any
%    alternative for HG1 (G621488). But once this geck is fixed in HG2,
%    this code will need to be revisited.

%-------------------------------------------------------------
function locCreateDynamicMenus(this)
% This is the callback that adds the below menus dynamically to the
% menu group in the Framework. These menus are created every time a user
% clicks on the "View" menu in the Framework. Adding menus dynamically when
% you have both main menus and context menus will ensure that the widgets
% always reflect the correct state of the underlying object.
% Menus added:
% 1) Options to view/hide dialogs within the panel
% 2) Auto-lock & Auto-hide the panel.
% 3) Option to control the vertical units of the Histogram Axis.

% Find the DialogMenu menu group from the View menu item.
hMgr = this.Application.UIMgr;
viewMenu = hMgr.findchild('Menus','View');

% Find all existing children and delete them before adding new menus.
mPanel = viewMenu.findchild('DialogPanelMenu');
delete(get(mPanel.WidgetHandle,'Children'));

% Get the main Dialog presenter object
dp = this.NTExplorerObj.ntx.dp;

% Build dialog related menus. Example: show/hide dialogs.
buildContextDialogSelection(dp,mPanel.WidgetHandle);

% Build menus for the Dialog Panel. Example: Auto-hide, Lock panel.
buildPanelMenuOptions(dp, mPanel.WidgetHandle);

% Find the Vertical units menu group and delete its children before
% creating new menus.
mVertical = viewMenu.findchild('VerticalUnits');
delete(get(mVertical.WidgetHandle,'Children'));

% Build menus for changing Y-Axis units. Example: Frequency/Count
buildVerticalUnitsMenu(this.NTExplorerObj.ntx, mVertical.WidgetHandle);

%-------------------------------
% [EOF]
