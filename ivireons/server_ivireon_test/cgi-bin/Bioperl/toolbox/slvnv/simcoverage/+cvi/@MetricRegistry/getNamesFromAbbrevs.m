
%   Copyright 2009 The MathWorks, Inc.

function [metricNames toMetricNames] = getNamesFromAbbrevs(settingStr, metricNamesStr)
metricNames = getMetricNames(settingStr);
toMetricNames = [];
if nargout > 1
    toMetricNames = getTOMetricNames(metricNamesStr);
end

function metricNames = getMetricNames(abbrevs)
dt = cvi.MetricRegistry.getMetricDescrTable;
fn = fieldnames(dt);
metricNames = [];
for idx = 1:numel(fn)
    cfn = fn{idx};
    if strfind(abbrevs,dt.(cfn){2})
        metricNames{end+1} = cfn; %#ok<AGROW>
    end
end

%==============================
function toMetricNames = getTOMetricNames(abbrevs)
toMetricNames = [];
if isempty(abbrevs)
    return;
end
pat ='\(\w*\)';
[starti endi] = regexp(abbrevs, pat);
    
dt = cvi.MetricRegistry.getGenericMetricMap;            

for idx = 1:numel(starti)
    mn = abbrevs(starti(idx) + 1 : endi(idx) - 1);
    if isfield(dt, mn)
        toMetricNames{end+1} = mn; %#ok<AGROW>
    end
end
