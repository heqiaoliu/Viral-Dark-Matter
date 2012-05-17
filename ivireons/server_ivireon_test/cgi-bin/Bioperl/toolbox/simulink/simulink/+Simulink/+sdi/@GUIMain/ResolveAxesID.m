function result = ResolveAxesID(this, TabType, AxesResultType)

    % Copyright 2009-2010 The MathWorks, Inc.

    switch TabType
    case Simulink.sdi.GUITabType.InspectSignals
        result = Simulink.sdi.AxesID.InspectSignalsData;
    case Simulink.sdi.GUITabType.CompareSignals
        switch AxesResultType
        case Simulink.sdi.GUIAxesResultType.Signals
            result = Simulink.sdi.AxesID.CompareSignalsData;
        case Simulink.sdi.GUIAxesResultType.Diff
            result = Simulink.sdi.AxesID.CompareSignalsDiff;
        end
    case Simulink.sdi.GUITabType.CompareRuns
        switch AxesResultType
        case Simulink.sdi.GUIAxesResultType.Signals
            result = Simulink.sdi.AxesID.CompareRunsData;
        case Simulink.sdi.GUIAxesResultType.Diff
            result = Simulink.sdi.AxesID.CompareRunsDiff;
        end
    end
end
