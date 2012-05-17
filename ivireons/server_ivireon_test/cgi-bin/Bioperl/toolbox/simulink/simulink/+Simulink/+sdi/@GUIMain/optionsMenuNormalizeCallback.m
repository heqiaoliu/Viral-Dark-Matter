function optionsMenuNormalizeCallback(this, s, ~)

%   Copyright 2010 The MathWorks, Inc.

    tabType = this.GetTabType;
    
    userData = get(this.OptionsMenu, 'userdata');
    axesID = userData.AxesID;
    
    switch tabType
    case Simulink.sdi.GUITabType.InspectSignals
        this.normInspectAxes = true;
    case Simulink.sdi.GUITabType.CompareSignals
        switch axesID
        case Simulink.sdi.AxesID.CompareSignalsData
            this.normCompSigDataAxes = true;
        case Simulink.sdi.AxesID.CompareSignalsDiff
            this.normCompSigDiffAxes = true;
        end
    case Simulink.sdi.GUITabType.CompareRuns
        switch axesID
        case Simulink.sdi.AxesID.CompareRunsData
            this.normCompRunsDataAxes = true;            
        case Simulink.sdi.AxesID.CompareRunsDiff
            this.normCompRunsDiffAxes = true;            
        end
    end
end

            
            
            
            
            
            