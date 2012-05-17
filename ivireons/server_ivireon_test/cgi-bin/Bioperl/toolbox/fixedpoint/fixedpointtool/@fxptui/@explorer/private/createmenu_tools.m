function m = createmenu_tools(h)
%CREATMENU_TOOLS   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/11/13 17:57:19 $

am = DAStudio.ActionManager;
m = am.createPopupMenu(h);

action = h.getaction('TOOLS_PROMPT_DLG_REPLACE');
m.addMenuItem(action);


% [EOF]