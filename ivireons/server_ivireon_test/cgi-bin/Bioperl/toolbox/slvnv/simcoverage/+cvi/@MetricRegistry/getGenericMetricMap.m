
%   Copyright 2009 The MathWorks, Inc.

function map = getGenericMetricMap

persistent pGenericMetricMap;


if isempty(pGenericMetricMap) 
    pGenericMetricMap = cvi.MetricRegistry.buildMap(pGenericMetricMap, cvi.MetricRegistry.getGenericMetricDescrTable, 2);         	    
    pGenericMetricMap = cvi.MetricRegistry.buildMap(pGenericMetricMap, cvi.MetricRegistry.getSldvMetricDescrTable, 2);         	    
end

map = pGenericMetricMap;

