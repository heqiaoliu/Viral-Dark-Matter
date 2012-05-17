%==================================        
function genResultsForSigbuilder(modelH, testInput)

%   Copyright 2007-2008 The MathWorks, Inc.
try
    topModelH = bdroot(modelH);

    resultSettings = cvi.ReportUtils.getAllOptions(topModelH);
    resultSettings.topModelName = get_param(topModelH, 'name');
    this.resultSettings.cumulativeReport = false; 
    
    
    if isa(testInput,'cvdata')
        all = {testInput};
    else
        all = testInput.getAll;
    end
    refModelCovObjs = [];
    for idx = 1:length(all)
        cto = all{idx};
        rootId = cto.rootID;
        currModelcovId = cv('get',rootId,'.modelcov');
        currentTest = cv('get',currModelcovId,'.currentTest');
        cvi.TopModelCov.updateResults(resultSettings, currentTest);
        refModelCovObjs(end+1) = currModelcovId; %#ok<*AGROW>
    end
    
    cvi.TopModelCov.genCovResults(testInput, resultSettings, refModelCovObjs )
catch MEx
    rethrow(MEx);
end

