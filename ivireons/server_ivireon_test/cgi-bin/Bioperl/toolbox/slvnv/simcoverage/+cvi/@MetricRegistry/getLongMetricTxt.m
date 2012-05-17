function metricLongDescr =  getLongMetricTxt(metricNames)

metricLongDescr = [];
if ~iscell(metricNames)
    metricNames = {metricNames};

end
dt1 = cvi.MetricRegistry.getGenericMetricMap;        
dt2 = cvi.MetricRegistry.getMetricDescrTable;
for idx = 1:numel(metricNames)
    mn = metricNames{idx};
    if isfield(dt1, mn)
        metricLongDescr  = [metricLongDescr {dt1.(mn){5}}]; %#ok<AGROW>
    else
        if isfield(dt2, mn)
            metricLongDescr  = [metricLongDescr {dt2.(mn){5}}]; %#ok<AGROW>
        end

    end
end
if numel(metricLongDescr) == 1
    metricLongDescr = metricLongDescr{1};
end