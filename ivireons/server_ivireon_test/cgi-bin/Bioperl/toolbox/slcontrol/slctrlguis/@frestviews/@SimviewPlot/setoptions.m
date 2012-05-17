function setoptions(this) 
% SETOPTIONS  Set the options for simView plot.
%
 
% Author(s): Erman Korkut 17-Jul-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/08/08 01:19:27 $

opts = this.PlotOptions;
% Set visibilities
this.TimePlot.AxesGrid.Visible = opts.TimeVisible;
this.SpectrumPlot.AxesGrid.Visible = opts.SpectrumVisible; 

% Time plot options
this.TimePlot.AxesGrid.Grid = opts.TimeGrid;
% Spectrum plot options
this.SpectrumPlot.AxesGrid.Grid = opts.SpectrumGrid;
this.SpectrumPlot.AxesGrid.XScale = opts.SpectrumFreqScale;
this.SpectrumPlot.AxesGrid.XUnits = opts.SpectrumFreqUnits;
this.SpectrumPlot.AxesGrid.YScale = opts.SpectrumAmpScale;
this.SpectrumPlot.AxesGrid.YUnits = opts.SpectrumAmpUnits;

% Summary plot options
if ~isempty(this.SummaryPlot)
    this.SummaryPlot.SummaryBode.AxesGrid.Visible = opts.SummaryVisible;
    this.SummaryPlot.SummaryBode.MagVisible = opts.SummaryMagVisible;
    this.SummaryPlot.SummaryBode.PhaseVisible = opts.SummaryPhaseVisible;
    this.SummaryPlot.SummaryBode.AxesGrid.Grid = opts.SummaryGrid;
    this.SummaryPlot.SummaryBode.AxesGrid.XScale = opts.SummaryFreqScale;
    this.SummaryPlot.SummaryBode.AxesGrid.XUnits = opts.SummaryFreqUnits;
    this.SummaryPlot.SummaryBode.AxesGrid.YScale = {opts.SummaryMagScale;opts.SummaryPhaseScale};
    this.SummaryPlot.SummaryBode.AxesGrid.YUnits = {opts.SummaryMagUnits;opts.SummaryPhaseUnits};
    this.SummaryPlot.SummaryBode.Options.UnwrapPhase = 'on';
end