function setup(this,hVisParent) 
% SETUP Create basic ui elements for the bode visualization
%
 
% Author(s): A. Stothert 09-Dec-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2010/05/10 17:58:00 $

%Create axis that will host response plot
%
%REVISIT: 
%
% would rather use hAx = axes('parent',hVisParent,'Visible','off');
% but this means elements drawn beyond the axes limits will show up in the
% hVisParent uicontainer
%
hFig = handle(get(get(hVisParent,'Parent'),'Parent'));
hAx = axes('parent',hFig,'Visible','off');
set(hFig,'renderer','opengl') %Needed as requirement patches are transparent

%Create a resppack.bodeplot for the visualization. At this point create
%plot for a 1x1 system but may have to change to nxm system at runtime.
this.hPlot = resppack.timeplot(hAx,[1 1],'Tag','step');
%Add plot options
setoptions(this.hPlot,plotopts.TimePlotOptions('cstprefs'));
this.hPlot.IOGrouping = 'all'; %Show MIMO systems on one set of axes

%Add context menus for the plot
this.addContextMenu;

%Make the plot visible
this.hPlot.AxesGrid.Grid = 'on';
this.hPlot.visible       = 'on';

%Add an event manager to manage undo/redo
this.setupUndo(hFig)
end