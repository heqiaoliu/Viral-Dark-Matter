function result = GetAxesYType(this, AxesID)

    % Copyright 2009-2010 The MathWorks, Inc.

    switch AxesID
    case Simulink.sdi.AxesID.InspectSignalsData
        result = this.AxesInspectSignalsType;
    case Simulink.sdi.AxesID.CompareSignalsData
        result = this.AxesCompareSignalsDataType;
    case Simulink.sdi.AxesID.CompareSignalsDiff
        result = this.AxesCompareSignalsDiffType;
    case Simulink.sdi.AxesID.CompareRunsData
        result = this.AxesCompareRunsDataType;
    case Simulink.sdi.AxesID.CompareRunsDiff
        result = this.AxesCompareRunsDiffType;
    end
end
