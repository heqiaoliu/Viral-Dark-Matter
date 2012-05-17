function optionsMenuOriginalCallback(this, ~, ~)
    % Copyright 2010 The MathWorks, Inc.

    tabType = this.GetTabType;
    
    userData = get(this.OptionsMenu, 'userdata');
    axesID = userData.AxesID;
    
    switch tabType
    case Simulink.sdi.GUITabType.InspectSignals
        this.normInspectAxes = false;
    case Simulink.sdi.GUITabType.CompareSignals
        switch axesID
        case Simulink.sdi.AxesID.CompareSignalsData
            this.normCompSigDataAxes = false;
        case Simulink.sdi.AxesID.CompareSignalsDiff
            this.normCompSigDiffAxes = false;
        end
    case Simulink.sdi.GUITabType.CompareRuns
        switch axesID
        case Simulink.sdi.AxesID.CompareRunsData
            this.normCompRunsDataAxes = false;            
        case Simulink.sdi.AxesID.CompareRunsDiff
            this.normCompRunsDiffAxes = false;            
        end
    end
end