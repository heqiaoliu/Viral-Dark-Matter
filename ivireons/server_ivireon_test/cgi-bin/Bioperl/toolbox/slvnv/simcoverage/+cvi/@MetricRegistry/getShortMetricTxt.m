function metricShortDescr =  getShortMetricTxt(metricNames)

metricShortDescr = [];
if ~iscell(metricNames)
    metricNames = {metricNames};

end
dt1 = cvi.MetricRegistry.getGenericMetricMap;        
dt2 = cvi.MetricRegistry.getMetricDescrTable;
for idx = 1:numel(metricNames)
    mn = metricNames{idx};
    if isfield(dt1, mn)
        metricShortDescr = [metricShortDescr {dt1.(mn){5}}]; %#ok<AGROW>
    else
  
        if isfield(dt2, mn)
            metricShortDescr  = [metricShortDescr {dt2.(mn){1}}]; %#ok<AGROW>
        end
    end
end
if numel(metricShortDescr) == 1
    metricShortDescr = metricShortDescr{1};
end