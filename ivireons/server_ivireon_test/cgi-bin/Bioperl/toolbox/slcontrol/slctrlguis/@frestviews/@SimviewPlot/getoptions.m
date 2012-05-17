function opt = getoptions(this)
% GETOPTIONS  Get the current set of options in the frest.simView figure
%
 
% Author(s): Erman Korkut 17-Jul-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/08/08 01:19:24 $


opt = this.PlotOptions;
% Get the options that are not updated with menu/right-click interactions
opt.TimeVisible = this.TimePlot.AxesGrid.Visible;
opt.SpectrumVisible = this.SpectrumPlot.AxesGrid.Visible;
opt.TimeGrid = this.TimePlot.AxesGrid.Grid;
opt.SpectrumGrid = this.SpectrumPlot.AxesGrid.Grid;
if ~isempty(this.SummaryPlot) 
    opt.SummaryVisible = this.SummaryPlot.SummaryBode.AxesGrid.Visible;
    opt.SummaryMagVisible = this.SummaryPlot.SummaryBode.MagVisible;
    opt.SummaryPhaseVisible = this.SummaryPlot.SummaryBode.PhaseVisible;
    opt.SummaryGrid = this.SummaryPlot.SummaryBode.AxesGrid.Grid;
end
