
function cvtest = copyMetricsFromModel(cvtest, modelName)
   %Create metrics that match models
	%NOTE: New default behavior is to match metric settings of model
	settingStr  = get_param(modelName, 'CovMetricSettings');
    %metricNamesStr  = get_param(modelName, 'CovMetricNames');
    metricNamesStr   = [];
	[metricNames toMetricNames] = cvi.MetricRegistry.getNamesFromAbbrevs(settingStr, metricNamesStr); %#ok<NASGU>
    allMetricNames  = cvi.MetricRegistry.getAllMetricNames;
    for i = 1:numel(allMetricNames)
        cvtest = setMetric(cvtest, allMetricNames{i}, 0);
    end %for

    for i = 1:numel(metricNames)
        cvtest = setMetric(cvtest, metricNames{i}, 1);
    end %for

    cv('set', cvtest.id, 'testdata.logicBlkShortcircuit', any(settingStr == 's'));
    cv('set', cvtest.id, 'testdata.forceBlockReductionOff', strcmpi(get_param(modelName, 'CovForceBlockReductionOff'), 'on'));
