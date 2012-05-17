
function setModelParams(this)

%   Copyright 2009-2010 The MathWorks, Inc.


    modelH = this.modelH;

    set_param(modelH,'CovPath',this.covPath);
    set_param(modelH,'CovSaveName',this.covSaveName);
    set_param(modelH,'CovCompData',this.covCompData);
    set_param(modelH,'CovHtmlReporting', boolToOnOff(this.covHtmlReporting));
    set_param(modelH,'CovNameIncrementing', boolToOnOff(this.covNameIncrementing));
    set_param(modelH,'RecordCoverage', boolToOnOff(this.recordCoverage));

    % Save the metric settings
    enabledMetrics = {};
    [~, allToMetricNames]= cvi.MetricRegistry.getAllMetricNames;
    enabledTOMetrics = [];
    metricStruct = cvi.MetricRegistry.getMetricsMetaInfo;
    for idx = 1:numel(metricStruct)
        mn = metricStruct(idx).cvtestFieldName;
        if (this.(mn)==1)
           if strcmpi(mn, 'designverifier')
            enabledTOMetrics = allToMetricNames;
            enabledMetrics{end+1} = 'testobjectives'; %#ok<AGROW>
           end
            enabledMetrics = [enabledMetrics mn]; %#ok<AGROW>
        end        
    end
    metricSettingStr = cvi.MetricRegistry.getAbbrevsFromNames(enabledMetrics, enabledTOMetrics);
    optionsStr = '';
    optionsTable = cv('Private', 'cv_dialog_options');
    [m, ~] = size(optionsTable);
    for idx = 1:m
        op = optionsTable{idx,4};
        isOn = (this.(op)==1);
        if strcmpi(op, 'forceBlockReductionOff')
            if isOn
                set_param(modelH, 'CovForceBlockReductionOff', 'on')
            else
                set_param(modelH, 'CovForceBlockReductionOff', 'off')
            end
        elseif isOn
            optionsStr = [optionsStr optionsTable{idx,2};]; %#ok<AGROW>
        end
    end
   
    % Use "e" to indicate that model coloring is disabled
    if ~this.modelDisplay 
        optionsStr = [optionsStr 'e'];
    end

    set_param(modelH,'CovMetricSettings',[metricSettingStr optionsStr]);
   
    % Save the HTML options

    htmlOptions = cvi.ReportUtils.getOptionsTable;
    htmlOptionsStr = [];
    [m, ~] = size(htmlOptions );
    for idx = 1:m
        if this.(htmlOptions{idx,2})
            v = '1';
        else
            v = '0';
        end
        htmlOptionsStr = [htmlOptionsStr ' -' htmlOptions{idx,3} '=' v ]; %#ok<AGROW>
    end

    set_param(modelH,'CovHTMLOptions',htmlOptionsStr);
    
    set_param(modelH, 'CovSaveCumulativeToWorkspaceVar', boolToOnOff(this.covSaveCumulativeToWorkspaceVar));
    set_param(modelH, 'CovSaveSingleToWorkspaceVar',     boolToOnOff(this.covSaveSingleToWorkspaceVar));
    set_param(modelH, 'CovCumulativeVarName',            this.covCumulativeVarName);
    if  strcmp(this.covCumulativeReport, 'Slvnv:simcoverage:covCumulativeReport1')
        set_param(modelH, 'CovCumulativeReport',             'on');
    else
        set_param(modelH, 'CovCumulativeReport',             'off');
    end
    set_param(modelH, 'CovReportOnPause',                boolToOnOff(this.covReportOnPause));


    set_param(modelH,'CovModelRefEnable', this.covModelRefEnable);
    set_param(modelH,'CovModelRefExcluded', this.covModelRefExcluded);
        
    set_param(modelH, 'CovExternalEMLEnable', boolToOnOff(this.covExternalEMLEnable));
    
%========================================
function OnOff = boolToOnOff(b)
    if b
        OnOff = 'on';
    else
        OnOff = 'off';
    end %if
