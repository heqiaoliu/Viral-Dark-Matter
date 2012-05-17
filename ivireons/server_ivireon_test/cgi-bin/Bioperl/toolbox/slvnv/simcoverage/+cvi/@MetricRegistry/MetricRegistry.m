%MetricRegistry

%   Copyright 2009 The MathWorks, Inc.

classdef MetricRegistry 
  methods(Static = true)
    metricName = cvmetricToStr(cvmetricHandle)      
    descrMap = buildMap(descrMap, descrTable, keyIdx)
    table = getMetricDescrTable
    table = getSldvMetricDescrTable
    map = getGenericMetricMap
    table = getGenericMetricDescrTable
    res = getDDEnumVals
    metricName  = getDVSupportedMaskTypes(maskName)
    [metricenumVals metricdescrIds] = registerMetric(cvmetricHandles)      
    enumVal = getEnum(metricName)      
    enumValStruct  = getAllEnums
    [allMetricNames allTOMetricNames] = getAllMetricNames
    [metricNames toMetricNames] = getNamesFromAbbrevs(settingStr, metricNamesStr);
    [settingStr metricNamesStr] = getAbbrevsFromNames(metricNames, toMetricNames)
    metricShortDescr =  getShortMetricTxt(metricNames)
    metricLongDescr =  getLongMetricTxt(metricNames)
    metricData = getMetricsMetaInfo    
  end
end
