function refreshAnalysisPlot(this)

%   Author(s): C. Buhr
%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2008/12/04 22:23:16 $

if isempty(this.AnalysisPlotConfig)
    this.AnalysisPlotConfig = sisogui.AnalysisPlotConfig(this.Parent);
    this.Handles.AnalysisPlotsTab.add(this.AnalysisPlotConfig.Handles.Panel,java.awt.BorderLayout.CENTER);
else
    this.AnalysisPlotConfig.refreshPanel;
end