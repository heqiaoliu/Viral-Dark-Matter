function refreshTab(this)

%   Author(s): C. Buhr
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:50:05 $

idx = this.Handles.TaskTabbedPane.getSelectedIndex + 1;

switch idx
    case 1 % Architecture Panel
        this.refreshArchitecture;

    case 2 % Manual Tunning
        this.refreshManualTuning;

    case 3 % Design  Plot Configuration
        this.refreshDesignPlot;

    case 4 % Design  Plot Configuration
        this.refreshAnalysisPlot;

    case 5 % Automated Tunning
        this.refreshAutomatedTuning;
end


