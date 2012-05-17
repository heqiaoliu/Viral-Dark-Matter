function m = createmenu_help(h)
%CREATMENU_HELP   

%   Author(s): G. Taillefer
%   Copyright 2006-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 20:00:00 $


am = DAStudio.ActionManager;
m = am.createPopupMenu(h);

action = h.getaction('HELP_FXPTTOOL');
m.addMenuItem(action);
m.addSeparator;

% Create the Simulink Fixed Point specific actions/menus if present.
if fxptui.isslfxptinstalled,
    
    m.addSeparator;

    action = h.getaction('HELP_SLFXPT');
    m.addMenuItem(action);
    m.addSeparator;

    action = h.getaction('HELP_SLFXPTDEMOS');
    m.addMenuItem(action);
    m.addSeparator;

    action = h.getaction('HELP_ABOUTSLFXPT');
    m.addMenuItem(action);

end

% [EOF]
