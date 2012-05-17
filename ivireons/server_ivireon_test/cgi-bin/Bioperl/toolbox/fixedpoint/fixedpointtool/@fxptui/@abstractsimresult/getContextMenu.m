function cm = getContextMenu(h, selectedHandles)
%GETCONTEXTMENU

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/11/13 17:57:07 $

me = fxptui.getexplorer;
am = DAStudio.ActionManager;
cm = am.createPopupMenu(me);

enabled = h.getcontextmenu_enabled;

action = me.getaction('VIEW_AUTOSCALEINFO');
action.enabled = enabled.VIEW_AUTOSCALEINFO;
cm.addMenuItem(action);
cm.addSeparator;

%--------------------------------------------------------------------------
action = me.getaction('VIEW_TSINFIGURE');
action.enabled = enabled.VIEW_TSINFIGURE;
cm.addMenuItem(action);

action = me.getaction('VIEW_HISTINFIGURE');
action.enabled = enabled.VIEW_HISTINFIGURE;
cm.addMenuItem(action);

action = me.getaction('VIEW_DIFFINFIGURE');
action.enabled = enabled.VIEW_DIFFINFIGURE;
cm.addMenuItem(action);
cm.addSeparator;

%--------------------------------------------------------------------------
%if this result points to a valid block enable block related menu items
action = me.getaction('HILITE_BLOCK');
action.enabled = enabled.HILITE_BLOCK;
cm.addMenuItem(action);

action = me.getaction('HILITE_CONNECTED_BLOCKS');
action.enabled = enabled.HILITE_CONNECTED_BLOCKS;
cm.addMenuItem(action);


action = me.getaction('HILITE_DTGROUP');
action.enabled = enabled.HILITE_DTGROUP;
cm.addMenuItem(action);

action = me.getaction('HILITE_CLEAR');
action.enabled = enabled.HILITE_CLEAR;
cm.addMenuItem(action);
cm.addSeparator;

%--------------------------------------------------------------------------
action = me.getaction('OPEN_BLOCKDIALOG');
action.enabled = enabled.OPEN_BLOCKDIALOG;
cm.addMenuItem(action);

action = me.getaction('OPEN_SIGNALDIALOG');
action.enabled = enabled.OPEN_SIGNALDIALOG;
cm.addMenuItem(action);
cm.addSeparator;
%--------------------------------------------------------------------------
action = me.getaction('RESULTS_STOREACTIVERUN');
cm.addMenuItem(action);

action = me.getaction('RESULTS_CLEARACTIVERUN');
cm.addMenuItem(action);

action = me.getaction('RESULTS_CLEARREFRUN');
cm.addMenuItem(action);

% [EOF]
