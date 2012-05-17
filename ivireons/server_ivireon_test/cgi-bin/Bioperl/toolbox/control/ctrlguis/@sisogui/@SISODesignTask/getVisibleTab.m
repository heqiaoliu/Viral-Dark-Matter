function Tab = getVisibleTab(this)

%   Author(s): C. Buhr
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:49:58 $

if ~ this.isVisible;
    Tab = 'None';
else
    idx = this.Handles.TaskTabbedPane.getSelectedIndex + 1;

    switch idx
        case 1 % Architecture Panel
            Tab = 'Architecture';

        case 2 % Manual Tunning
            Tab = 'PZEditor';

        case 3 % Design Plot Configuration
            Tab = 'DesignPlot';

        case 4 % Design Plot Configuration
            Tab = 'AnalysisPlot';

        case 5 % Automated Tunning
            Tab = 'SROTuning';
    end
end


