function refreshDesignPlot(this)

%   Author(s): C. Buhr
%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2008/12/04 22:23:22 $

if isempty(this.DesignPlotConfig)
    this.DesignPlotConfig = sisogui.DesignPlotConfig(this.Parent);
    this.Handles.DesignPlotsTab.add(this.DesignPlotConfig.Handles.Panel,java.awt.BorderLayout.CENTER);
else
    this.DesignPlotConfig.refreshPanel;
end

