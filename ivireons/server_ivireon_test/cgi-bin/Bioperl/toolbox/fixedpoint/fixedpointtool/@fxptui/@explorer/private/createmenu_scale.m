function m = createmenu_scale(h)
%CREATEMENU_DATA

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/09/13 06:52:53 $

am = DAStudio.ActionManager;
m = am.createPopupMenu(h);

action = h.getaction('SCALE_PROPOSE');
m.addMenuItem(action);

action = h.getaction('SCALE_APPLY');
m.addMenuItem(action);

action = h.getaction('VIEW_AUTOSCALEINFO');
m.addMenuItem(action);

% [EOF]
