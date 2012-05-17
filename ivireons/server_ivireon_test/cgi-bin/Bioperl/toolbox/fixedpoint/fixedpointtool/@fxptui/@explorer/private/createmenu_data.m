function m = createmenu_data(h)
%CREATEMENU_DATA

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/09/13 06:52:52 $

am = DAStudio.ActionManager;
m = am.createPopupMenu(h);

action = h.getaction('RESULTS_SWAPRUNS');
m.addMenuItem(action);
m.addSeparator

action = h.getaction('RESULTS_STOREACTIVERUN');
m.addMenuItem(action);

action = h.getaction('RESULTS_STOREREFRUN');
m.addMenuItem(action);

m.addSeparator;
action = h.getaction('RESULTS_CLEARACTIVERUN');
m.addMenuItem(action);

action = h.getaction('RESULTS_CLEARREFRUN');
m.addMenuItem(action);
m.addSeparator;

% [EOF]
