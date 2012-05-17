function setup(this,hVisParent) 
% SETUP Create basic ui elements for the pzmap visualization
%
 
% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2010/05/10 17:58:02 $

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

%Create a resppack.plot for the visualization. At this point create
%plot for a 1x1 system but may have to change to nxm system at runtime.
%
switch this.PlotType
   case 'table'
      this.hPlot = slctrlguis.checkblkviews.GainPhaseTableVisual(this,hVisParent);
   case 'nyquist'
      this.hPlot = resppack.nyquistplot(hAx,[1 1]);
      setoptions(this.hPlot,plotopts.NyquistPlotOptions('cstprefs'));
   case 'bode'
      this.hPlot = resppack.bodeplot(hAx,[1 1]);
      setoptions(this.hPlot,plotopts.BodePlotOptions('cstprefs'));
   otherwise
      %Default to Nichols plot
      set(hFig,'renderer','opengl') %Needed as requirement patches are transparent
      this.hPlot = resppack.nicholsplot(hAx,[1 1]);
      setoptions(this.hPlot,plotopts.NicholsPlotOptions('cstprefs'));
end

if ~strcmp(this.PlotType,'table')
   L = handle.listener(this.Application,'DataSourceChanged',{@localDataSourceChanged this});
   this.Listeners = [this.Listeners; L];
   
   this.hPlot.IOGrouping = 'all'; %Show MIMO systems on one set of axes

   %Add context menus for the plot
   this.addContextMenu;
   
   %Make the plot visible
   this.hPlot.AxesGrid.Grid = 'on';
   this.hPlot.visible       = 'on';
end

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

switch hBlk.PlotType
   case 'nyquist'
      %Axes units are Re & Im, no units.
   case 'nichols'
      this.hPlot.AxesGrid.XUnits = hBlk.PhaseUnits;
      %Magnitude units (Y-axis) must be 'dB' and cannot change
   case 'bode'
      this.hPlot.AxesGrid.XUnits = hBlk.FrequencyUnits;
      this.hPlot.AxesGrid.YUnits = {hBlk.MagnitudeUnits; hBlk.PhaseUnits};
end
end

