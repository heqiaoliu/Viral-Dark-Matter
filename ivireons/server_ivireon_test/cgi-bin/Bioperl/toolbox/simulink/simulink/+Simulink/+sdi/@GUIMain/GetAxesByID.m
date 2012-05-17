function result = GetAxesByID(this, AxesID)

    % Copyright 2009-2010 The MathWorks, Inc.

    switch AxesID
    case Simulink.sdi.AxesID.InspectSignalsData
        result = this.AxesInspectSignals;
    case Simulink.sdi.AxesID.CompareSignalsData
        result = this.AxesCompareSignalsData;
    case Simulink.sdi.AxesID.CompareSignalsDiff
        result = this.AxesCompareSignalsDiff;
    case Simulink.sdi.AxesID.CompareRunsData
        result = this.AxesCompareRunsData;
    case Simulink.sdi.AxesID.CompareRunsDiff
        result = this.AxesCompareRunsDiff;
    end
end