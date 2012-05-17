function createmenu(h)
%CREATEMENU   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/10 21:33:55 $

am = DAStudio.ActionManager;

m = createmenu_file(h);
am.addSubMenu(h, m, DAStudio.message('FixedPoint:fixedPointTool:menuFile'));

m = createmenu_scale(h);
am.addSubMenu(h, m, DAStudio.message('FixedPoint:fixedPointTool:menuAutoscaling'));

m = createmenu_data(h);
am.addSubMenu(h, m, DAStudio.message('FixedPoint:fixedPointTool:menuResults'));

m = createmenu_run(h);
am.addSubMenu(h, m, DAStudio.message('FixedPoint:fixedPointTool:menuSimulation'));

m = createmenu_view(h);
am.addSubMenu(h, m, DAStudio.message('FixedPoint:fixedPointTool:menuView'));

m = createmenu_tools(h);
am.addSubMenu(h, m, DAStudio.message('FixedPoint:fixedPointTool:menuTools'));




m = createmenu_help(h);
am.addSubMenu(h, m, DAStudio.message('FixedPoint:fixedPointTool:menuHelp'));

% [EOF]