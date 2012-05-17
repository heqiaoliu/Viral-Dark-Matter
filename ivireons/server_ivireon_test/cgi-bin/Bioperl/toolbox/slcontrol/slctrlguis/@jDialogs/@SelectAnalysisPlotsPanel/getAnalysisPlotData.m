function AnalysisPlotData = getAnalysisPlotData(this) 
% GETANALYSISPLOTDATA  Get the selected analysis plots.
%
 
% Author(s): John W. Glass 12-Oct-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/12/14 15:28:37 $

% Get the Analysis view table data 
PlotTypeSel = this.Handles.SelectAnalysisPlotsPanel.TablePanel.getPlotCombos;
TableData = cell(this.Handles.SelectAnalysisPlotsPanel.TablePanel.getPlotContentTableModel.data);

AnalysisPlotData = [];
idx = 1;
plottags = {'step'; 'impulse'; 'bode';'nyquist'; 'nichols'; 'pzmap'};
for ct = 1:length(PlotTypeSel)
    PlotIndex = PlotTypeSel(ct).getSelectedIndex;
    if PlotIndex > 0
        AnalysisPlotData(idx).PlotType = plottags(PlotIndex);
        AnalysisPlotData(idx).VisibleModels = find(cell2mat(TableData(:,ct)));
        idx = idx+1;
    end
end