function m = createmenu_file(h)
%CREATMENU_FILE   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:59:59 $

am = DAStudio.ActionManager;
m = am.createPopupMenu(h);

% action = h.getaction('FILE_NEW');
% m.addMenuItem(action);
% 
% action = h.getaction('FILE_OPEN');
% m.addMenuItem(action);

action = h.getaction('FILE_CLOSE');
m.addMenuItem(action);

% [EOF]