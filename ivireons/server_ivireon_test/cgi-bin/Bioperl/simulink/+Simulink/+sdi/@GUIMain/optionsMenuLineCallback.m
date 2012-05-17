function optionsMenuLineCallback(this, ~, ~, lineStair)

%   Copyright 2010 The MathWorks, Inc.

    tabType = this.GetTabType;        
    userData = get(this.OptionsMenu, 'userdata');
    axesID = userData.AxesID;
    
    switch tabType
    case Simulink.sdi.GUITabType.InspectSignals
        this.stairLineInspectAxes = lineStair;
    case Simulink.sdi.GUITabType.CompareSignals
        switch axesID
        case Simulink.sdi.AxesID.CompareSignalsData
            this.stairLineCompSigDataAxes = lineStair;
        case Simulink.sdi.AxesID.CompareSignalsDiff
            this.stairLineCompSigDiffAxes = lineStair;
        end
    case Simulink.sdi.GUITabType.CompareRuns
        switch axesID
        case Simulink.sdi.AxesID.CompareRunsData
            this.stairLineCompRunsDataAxes = lineStair;            
        case Simulink.sdi.AxesID.CompareRunsDiff
            this.stairLineCompRunsDiffAxes = lineStair;            
        end
    end
end
            
            
            
            
            
            