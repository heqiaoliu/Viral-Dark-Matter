
%   Copyright 2009 The MathWorks, Inc.

function enumVals = getEnum(metricNames)      
enumVals = [];
if ~iscell(metricNames)
    metricNames = {metricNames};
end
for idx = 1:numel(metricNames)
    mn = metricNames{idx};
    dt = cvi.MetricRegistry.getMetricDescrTable;
    enumVal = [];
    if isfield(dt, mn)
       enumVals = [enumVals  dt.(mn){4}]; %#ok<AGROW>
    else
        dt = cvi.MetricRegistry.getGenericMetricMap;        
        if isfield(dt, mn)
            enumVals = [enumVals  dt.(mn){4}]; %#ok<AGROW>
        end
    end
    enumVals = [enumVals  enumVal]; %#ok<AGROW>    
end

