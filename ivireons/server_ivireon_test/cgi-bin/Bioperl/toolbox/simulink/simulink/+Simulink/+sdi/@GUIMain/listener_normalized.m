function listener_normalized(this, src, ~)

%   Copyright 2010 The MathWorks, Inc.

    switch src.Name % switch on the property name
        case 'normInspectAxes'
            this.updateInspAxes();
        case 'normCompSigDataAxes'
            this.transferStateToScreen_plotUpdateCompareSignals();
        case 'normCompSigDiffAxes'
            this.transferStateToScreen_plotUpdateCompareSignals();
        case 'normCompRunsDataAxes'
            this.plotUpdateCompRuns(this.state_SelectedSignalCompRun);
        case 'normCompRunsDiffAxes'
            this.plotUpdateCompRuns(this.state_SelectedSignalCompRun);
    end
end


        
        