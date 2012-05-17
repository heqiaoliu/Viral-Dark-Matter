
%   Copyright 2008 The MathWorks, Inc.

function modelTerm(modelH)
try
compileForCoverage = strcmpi(get_param(modelH,'compileForCoverageInProgress'),'on');
modelCovId = get_param(modelH, 'CoverageId');
if  modelCovId ==0 
    return
end
coveng = cvi.TopModelCov.getInstance(modelH);

if coveng.isLastReporting(modelH)    
    allModelcovIds  = coveng.getAllModelcovIds;
    if ~compileForCoverage && ~checkUnfinishedInitialization(allModelcovIds)
        if ~cv('Private', 'cv_autoscale_settings', 'isForce', modelH);
            coveng.checkCumDataConsistency;    
        end
        onlyAutoscale = true;
        for currModelcovId = allModelcovIds(:)'
            cv('ModelcovTerm',currModelcovId);  
            if ~coveng.isCvCmdCall
                currentTest = cv('get',currModelcovId,'.currentTest');
                isForced = model_autoscale(currModelcovId, currentTest);
                if ~isForced
                    cvi.TopModelCov.updateResults(coveng.resultSettings, currentTest);
                end
                onlyAutoscale = onlyAutoscale && isForced;
            end
        end        
        if ~coveng.isCvCmdCall && ~onlyAutoscale
            coveng.genResults();
        end
    end  
    cleanUp(allModelcovIds);
    if ~coveng.isCvCmdCall
        cvi.TopModelCov.termFromTopModel(modelH);
    end
    
end
catch MEx
    cleanUp(coveng.getAllModelcovIds);
    rethrow(MEx);
end

function cleanUp(allModelcovIds)

for currModelcovId = allModelcovIds(:)'
    cv('ModelcovClear',currModelcovId);
end        

%==========================================
%e.g. modelStart failed in simulink and modelTerm is called
function res = checkUnfinishedInitialization(allModelcovIds)
res  = false;
for currModelcovId = allModelcovIds(:)'
    currentTestId = cv('get',currModelcovId,'.currentTest');
    % one possible symptom is not initialized current test variable
    if currentTestId == 0
        res = true;
    end
end        


%==========================================
function isForce = model_autoscale(currModelcovId, activeTestId)
isForce = false;
if cv('get', currModelcovId, '.isScript')
    return;
end
modelH = cv('get', currModelcovId, '.handle');
if ~strcmpi(get_param(modelH, 'CovAutoscale'), 'on');
    return;
end
% Get range structure
covData = cvdata(activeTestId);

% Add data to structure
cv('Private', 'cv_append_autoscale_data',covData);

% If we forced coverage, restore settings and return early
isForce = cv('Private', 'cv_autoscale_settings', 'isForce', modelH);

cv('Private', 'cv_autoscale_settings', 'restore', modelH);


