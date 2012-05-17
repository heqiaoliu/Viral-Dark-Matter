

%   Copyright 2009 The MathWorks, Inc.

function [allMetricNames allTOMetricNames] = getAllMetricNames

allMetricNames  = fieldnames(cvi.MetricRegistry.getMetricDescrTable)';
allTOMetricNames = [];
if nargout > 1
    allTOMetricNames = fieldnames(cvi.MetricRegistry.getGenericMetricMap)';
end
