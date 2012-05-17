function setup(this,hVisParent) 
% SETUP Create basic ui elements for the bode visualization
%
 
% Author(s): A. Stothert 09-Dec-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2010/05/10 17:58:08 $

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

%Create a resppack.sigmaplot for the visualization.
this.hPlot = resppack.sigmaplot(hAx);
%Create a listener for data source connection events on the application
L = handle.listener(this.Application,'DataSourceChanged',{@localDataSourceChanged this});
this.Listeners = [this.Listeners; L];

%Add plot options
setoptions(this.hPlot,plotopts.SigmaPlotOptions('cstprefs'));
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
this.hPlot.AxesGrid.XUnits = hBlk.FrequencyUnits;
this.hPlot.AxesGrid.YUnits = hBlk.MagnitudeUnits;
end