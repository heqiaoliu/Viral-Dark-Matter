function cvtest= setMetric(cvtest, metricName, value)
    id = cvtest.id;
    if strcmpi(metricName, 'testobjectives') 
        if value == 1
            [~, allTOMetricNames] = cvi.MetricRegistry.getAllMetricNames;
            createMetricData(id, allTOMetricNames);   
        else
            createMetricData(id, []);   
        end
        cv('set',id,['testdata.settings.' metricName], value);
    else
        enumVal = cvi.MetricRegistry.getEnum(metricName);
        if enumVal>-1
            cv('set',id,['testdata.settings.' metricName], value);
        else
            invalid_subscript;
        end
    end

 function createMetricData(id, metricNames)   
    metricdataIds = cv('get', id, 'testdata.testobjectives');
    setIdx = []; 
    for i = 1:numel(metricNames)
       cmn = metricNames{i};
       metricenumValue = cvi.MetricRegistry.getEnum(cmn);
       if ~isempty(metricdataIds ) && metricenumValue< numel(metricenumValue) && metricdataIds(metricenumValue) ~= 0
            assert(strcmpi(cv('get', newMetricdataIds(metricenumValue), '.metricName'), cmn )); 
       else
            metricdataIds(metricenumValue) = cv('new', 'metricdata', '.metricName', cmn, '.metricenumValue',metricenumValue);
       end
       setIdx(end+1) = metricenumValue; %#ok<AGROW>
    end
    %delete the prevoius metric settings
    unsetIdx = setdiff((1:numel(metricdataIds)),setIdx );
    metricdataIds(unsetIdx) = 0;
    toDelmetricdataIds = metricdataIds(unsetIdx);
    toDelmetricdataIds(toDelmetricdataIds == 0) = [];
    if ~isempty(toDelmetricdataIds)
        cv('delete', toDelmetricdataIds);
    end
    cv('set', id, 'testdata.testobjectives', metricdataIds);