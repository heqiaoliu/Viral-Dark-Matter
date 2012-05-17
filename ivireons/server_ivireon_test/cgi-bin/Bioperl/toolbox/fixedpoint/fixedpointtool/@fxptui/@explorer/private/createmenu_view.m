function m = createmenu_view(h)
%CREATMENU_VIEW

%   Author(s): G. Taillefer
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/09/09 21:07:33 $

am = DAStudio.ActionManager;
m = am.createPopupMenu(h);

action = h.getaction('VIEW_TSINFIGURE');
m.addMenuItem(action);

action = h.getaction('VIEW_HISTINFIGURE');
m.addMenuItem(action);

action = h.getaction('VIEW_DIFFINFIGURE');
m.addMenuItem(action);
m.addSeparator;

action = h.getaction('HILITE_BLOCK');
m.addMenuItem(action);

action = h.getaction('HILITE_CONNECTED_BLOCKS');
m.addMenuItem(action);

action = h.getaction('HILITE_DTGROUP');
m.addMenuItem(action);

action = h.getaction('HILITE_CLEAR');
m.addMenuItem(action);
m.addSeparator;

action = h.getaction('VIEW_SHOWDYNDLGS');
m.addMenuItem(action);

action = h.getaction('VIEW_CUSTPROPSPANE');
m.addMenuItem(action);
m.addSeparator;

action = h.getaction('VIEW_INCREASEFONT');
m.addMenuItem(action);
action = h.getaction('VIEW_DECREASEFONT');
m.addMenuItem(action);

% [EOF]
