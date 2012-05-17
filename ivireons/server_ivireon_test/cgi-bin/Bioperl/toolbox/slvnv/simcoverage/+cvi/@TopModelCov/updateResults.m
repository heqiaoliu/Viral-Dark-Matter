%==================================        
function updateResults(resultSettings, testId)

%   Copyright 2007-2008 The MathWorks, Inc.
    
    if resultSettings.saveCumulativeToWorkspaceVar ||  ...
        resultSettings.covCumulativeReport
        update_running_total(testId);
    end
    
%==================================        
 function update_running_total(testId)
        
        testObj = cvdata(testId);
        rootId = testObj.rootID;
		%Calculate cumulative results
		oldTotalId = cv('get', rootId, '.runningTotal');
		currentRun = testObj;
		if (isempty(oldTotalId) || oldTotalId == 0)
			newTotal = testObj;
		else %if (oldTotalId == 0)
			oldTotal = cvdata(oldTotalId);
			newTotal = currentRun + oldTotal;
			%Commit derived data to data dictionary
			newTotal = commitdd(newTotal);
		end; 

		%Record cumulative results
		cv('set', rootId, '.runningTotal', newTotal.id);
        cv('set', rootId, '.prevRunningTotal', oldTotalId);
    
