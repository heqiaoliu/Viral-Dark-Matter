 function displayAllModelParams(modelH)

%   Copyright 2010 The MathWorks, Inc.

    params = {'CovPath', 'CovSaveName', 'CovCompData', 'CovMetricSettings', ...
        'CovForceBlockReductionOff', 'CovHtmlReporting', 'CovHTMLOptions', 'CovSaveCumulativeToWorkspaceVar', ...
        'CovSaveSingleToWorkspaceVar', 'CovCumulativeVarName', ...
        'CovCumulativeReport', 'CovReportOnPause', 'RecordCoverage', ...
        'CovModelRefEnable', 'CovModelRefExcluded', 'CovNameIncrementing','CovExternalEMLEnable'};
    displayParams(modelH, params);
    
   function displayParams(modelH, params)
       str = '';
       for idx = 1:numel(params)
           str = [str sprintf('%s = %s \n', params{idx}, get_param(modelH, params{idx}))]; %#ok<AGROW>
       end
       str