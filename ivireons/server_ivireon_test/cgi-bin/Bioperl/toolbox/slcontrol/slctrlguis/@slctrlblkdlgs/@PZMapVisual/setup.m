function setup(this,hVisParent) 
% SETUP Create basic ui elements for the pzmap visualization
%
 
% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2010/05/10 17:58:06 $

%Create axis that will host response plot
%
%REVISIT: 
%
% would rather use hAx = axes('parent',hVisParent,'Visible','off');
% but this means elements drawn beyond the axes limits will show up in the
% hVisParent uicontainer
%
hFig = handle(get(get(hVisParent,'Parent'),'Parent'));
set(hFig,'renderer','opengl') %needed as requirement patches are transparent
hAx = axes('parent',hFig,'Visible','off');

%Create a resppack.bodeplot for the visualization. At this point create
%plot for a 1x1 system but may have to change to nxm system at runtime.
this.hPlot = resppack.pzplot(hAx,[1 1]);
%Create a listener for data source connection events on the application
L = handle.listener(this.Application,'DataSourceChanged',{@localDataSourceChanged this});
this.Listeners = [this.Listeners; L];

%Add plot options
setoptions(this.hPlot,plotopts.PZMapOptions('cstprefs'));
this.hPlot.IOGrouping = 'all'; %Show MIMO systems on one set of axes

%Add context menus for the plot
this.addContextMenu;

%Make the plot visible
this.hPlot.AxesGrid.Grid = 'on';
this.hPlot.visible       = 'on';

%Add an event manager to manage undo/redo
this.setupUndo(hFig)
end

function localDataSourceChanged(~,~,this)
%The Data source has been connected to the application, apply any source
%specific configurations to the visual. Note that the application is for a
%wired scope so the source should never change after the application is 
%created.

hBlk = this.Application.DataSource.BlockHandle;
prefs = cstprefs.tbxprefs;
if isempty(hBlk.FrequencyUnits)
   hBlk.FrequencyUnits = prefs.FrequencyUnits;
end
if isempty(hBlk.MagnitudeUnits)
   hBlk.MagnitudeUnits = prefs.MagnitudeUnits;
end
if isempty(hBlk.PhaseUnits)
   hBlk.PhaseUnits = prefs.PhaseUnits;
end
end