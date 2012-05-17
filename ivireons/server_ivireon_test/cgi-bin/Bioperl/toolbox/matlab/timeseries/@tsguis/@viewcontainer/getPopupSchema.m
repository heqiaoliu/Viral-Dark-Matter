function menu = getPopupSchema(this,manager)
% GETPOPUPSCHEMA Constructs the default popup menu

% Author(s): James G. Owen
% Revised: 
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2005/12/15 20:58:15 $

%% Create menus
menu  = com.mathworks.mwswing.MJPopupMenu;
menuAddPlot = com.mathworks.mwswing.MJMenuItem(xlate('New Plot...'));
menu.add(menuAddPlot);

%% Assign menu callbacks
set(handle(menuAddPlot,'callbackproperties'),'ActionPerformedCallback',...
    @(es,ed) addPlot(get(get(manager,'Root'),'tsViewer'),get(this,'Label')))
