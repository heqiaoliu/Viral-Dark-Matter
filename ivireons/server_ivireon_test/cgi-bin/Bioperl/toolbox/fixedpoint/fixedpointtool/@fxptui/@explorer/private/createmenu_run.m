function m = createmenu_run(h)
%CREATMENU_RUN   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 20:00:01 $

am = DAStudio.ActionManager;
m = am.createPopupMenu(h);

action = h.getaction('START');
m.addMenuItem(action);

action = h.getaction('PAUSE');
m.addMenuItem(action);

action = h.getaction('STOP');
m.addMenuItem(action);

% [EOF]