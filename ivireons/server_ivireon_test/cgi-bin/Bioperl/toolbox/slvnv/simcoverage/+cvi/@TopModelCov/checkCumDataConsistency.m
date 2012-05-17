%=======================================
function checkCumDataConsistency(this)

%   Copyright 2008 The MathWorks, Inc.
    
    
    if this.isCvCmdCall
        return;
    end
    if ~this.resultSettings.saveCumulativeToWorkspaceVar &&  ...
        ~this.resultSettings.covCumulativeReport
        return;
    end 
    allModelcovIds = this.getAllModelcovIds;
    resetIt = false;
    if ~isempty(this.oldModelcovIds) && ~isequal(this.oldModelcovIds, allModelcovIds)
        resetIt = true;
    end
    rootIds = [];
    for currModelcovId = allModelcovIds(:)'
        currentTest = cv('get',currModelcovId,'.currentTest');
        testObj = cvdata(currentTest);
        rootIds(end+1) = testObj.rootID; %#ok<AGROW>
    end
    if ~resetIt 

        rt = cv('get', rootIds, '.runningTotal');
        %mixed values, zeros and not zeros
        resetIt = ~all(rt) && any(rt);
    end

    if resetIt
        for cr = rootIds(:)'
            cv('set', cr, '.runningTotal',0);
            cv('set', cr, '.prevRunningTotal',0);
        end
    end
