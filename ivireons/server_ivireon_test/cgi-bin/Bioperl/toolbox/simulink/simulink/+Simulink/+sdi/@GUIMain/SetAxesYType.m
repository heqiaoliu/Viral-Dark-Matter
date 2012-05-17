function SetAxesYType(this, AxesID, AxesYType)

    % Copyright 2009-2010 The MathWorks, Inc.

    switch AxesID
    case InspectSignalsData, this.AxesInspectSignalsType     = AxesYType;
    case CompareSignalsData, this.AxesCompareSignalsDataType = AxesYType;
    case CompareSignalsDiff, this.AxesCompareSignalsDiffType = AxesYType;
    case CompareRunsData,    this.AxesCompareRunsDataType    = AxesYType;
    case CompareRunsDiff,    this.AxesCompareRunsDiffType    = AxesYType;
    end
end
