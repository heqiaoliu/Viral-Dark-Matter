
%   Copyright 2008 The MathWorks, Inc.

function modelPause(modelH)
try

modelCovId = get_param(modelH, 'CoverageId');
if  modelCovId ==0 
    return
end
coveng = cvi.TopModelCov.getInstance(modelH);
if ~coveng.resultSettings.covReportOnPause 
    return;
end

if coveng.isLastReporting(modelH)    
    
    coveng.checkCumDataConsistency;
    allModelcovIds  = coveng.getAllModelcovIds;
    for currModelcovId = allModelcovIds(:)'

        cv('ModelPause',currModelcovId);  
        if ~coveng.isCvCmdCall
            currentTest = cv('get',currModelcovId,'.currentTest');
            cvi.TopModelCov.updateResults(coveng.resultSettings, currentTest);
        end
    end        
    if ~coveng.isCvCmdCall && ~cv('Private', 'cv_autoscale_settings', 'isForce', modelH)
        coveng.genResults();
    end
   
end
catch MEx
    rethrow(MEx);
end
