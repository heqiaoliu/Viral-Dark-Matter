
%   Copyright 2009 The MathWorks, Inc.

function [settingStr metricNamesStr] = getAbbrevsFromNames(metricNames, toMetricNames)
settingStr = getAbbrev(metricNames, cvi.MetricRegistry.getMetricDescrTable, 2);
metricNamesStr = getTOAbbrev(toMetricNames, cvi.MetricRegistry.getGenericMetricMap, 2);

function abbrev = getAbbrev(metricNames, dt, propIdx)
abbrev = [];
if ~iscell(metricNames)
    metricNames = {metricNames};
end
for idx = 1:numel(metricNames)
    mn = metricNames{idx};
    if isfield(dt, mn)
       abbrev  = [abbrev dt.(mn){propIdx}]; %#ok<AGROW>
    end
end


function abbrev = getTOAbbrev(metricNames, dt, propIdx)
abbrev = [];
if ~iscell(metricNames)
    metricNames = {metricNames};
end
for idx = 1:numel(metricNames)
    mn = metricNames{idx};
    if isfield(dt, mn)
       abbrev  = [abbrev   '(' dt.(mn){propIdx} ')']; %#ok<AGROW>
    end
end
