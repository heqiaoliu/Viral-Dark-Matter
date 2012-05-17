 function getModelParams(this)

%   Copyright 2009-2010 The MathWorks, Inc.

    modelH = this.modelH;


    this.covPath = get_param(modelH,'CovPath');
    
    this.covSaveName = get_param(modelH,'CovSaveName');
    this.covCompData = get_param(modelH,'CovCompData');
    getHtmlOptions(this, modelH);
    this.CovNameIncrementing = strcmp(get_param(modelH,'CovNameIncrementing'),'on');
    
    % Get Coverage metric settings string

        settingStr = get_param(modelH,'CovMetricSettings');
        metricNamesStr = []; 
        [enabledMetricNames enabledTOMetricNames] = cvi.MetricRegistry.getNamesFromAbbrevs(settingStr,metricNamesStr ); %#ok<NASGU>
        for idx = 1:numel(enabledMetricNames)
            if strcmp(enabledMetricNames{idx}, 'testobjectives')
                this.designverifier  = true;
            else
                this.(enabledMetricNames{idx}) = true;
            end
        end
        
        if strcmpi(get_param(modelH, 'CovForceBlockReductionOff'), 'on')
            settingStr = [settingStr 'f'];
        end
        enabledOptionTags = cv('Private','cv_dialog_options','enabledTags',settingStr);
        [m, ~] = size(enabledOptionTags);
        for idx = 1:m
            this.(enabledOptionTags{idx,3}) = enabledOptionTags{idx,2};
        end
        
        % "e" is reserved in the settingStr for disabling the editor (or
        % Model) coverage display
    this.modelDisplay = ~any(settingStr == 'e');
    this.covHTMLOptions = get_param(modelH,'CovHTMLOptions');


    this.covSaveCumulativeToWorkspaceVar = strcmpi(get_param(modelH, 'CovSaveCumulativeToWorkspaceVar'), 'on');
    this.covSaveSingleToWorkspaceVar = strcmpi(get_param(modelH, 'CovSaveSingleToWorkspaceVar'), 'on');
    this.covCumulativeVarName = get_param(modelH, 'CovCumulativeVarName');
    if strcmpi(get_param(modelH, 'CovCumulativeReport'), 'on');
        this.covCumulativeReport = 'Slvnv:simcoverage:covCumulativeReport1';
    else
        this.covCumulativeReport = 'Slvnv:simcoverage:covCumulativeReport2';
    end
    this.covReportOnPause = strcmpi(get_param(modelH, 'CovReportOnPause'), 'on');
    this.recordCoverage = strcmpi(get_param(modelH,'RecordCoverage'),'on');
    this.covModelRefEnable = get_param(modelH,'CovModelRefEnable');
    this.modelRefEnable = ~strcmpi(this.covModelRefEnable, 'off');
    this.covModelRefExcluded = get_param(modelH,'CovModelRefExcluded');
    if strcmpi(this.covModelRefEnable,'filtered') &&  ~isempty(this.covModelRefExcluded)
       commas = length(strfind(this.covModelRefExcluded,','));
       this.mdlRefSelStatus = DAStudio.message('Slvnv:simcoverage:numOfExcludedModels', commas+1);
    else
       this.mdlRefSelStatus = DAStudio.message('Slvnv:simcoverage:allReferencedMdlsIncluded');
    end

    this.covNameIncrementing = strcmp(get_param(modelH,'CovNameIncrementing'),'on');
    this.covExternalEMLEnable = strcmp(get_param(modelH,'CovExternalEMLEnable'),'on');

    this.covHtmlReporting= strcmpi(get_param(modelH,'CovHtmlReporting'), 'on');
%=================================
function getHtmlOptions(this, modelH)
    
    optionsTable =  cvi.ReportUtils.getOptionsTable;
    htmlOptions = get_param(modelH,'CovHTMLOptions');
    options = cvi.ReportUtils.parseOptionString([], htmlOptions);
    [optCnt, ~] = size(optionsTable); 
    for i=1:optCnt
        if ~strcmp(optionsTable{i,1},'>----------')
            optStr = optionsTable{i,2};
            this.(optStr) = options.(optStr);
            
        end
    end
