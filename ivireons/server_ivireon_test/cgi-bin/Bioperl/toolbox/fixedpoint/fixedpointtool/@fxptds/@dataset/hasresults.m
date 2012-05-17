function b = hasresults(h)
%HASRESULTS returns true if dataset contains results

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2010/04/05 22:16:39 $

b = false;
if  h.isSDIEnabled
    for i = 1:h.RunIDMap.getCount
        % get the RunID for each run
        runID = h.RunIDMap.getDataByIndex(i);
        if isempty(runID); continue; end;
        if (h.SDIEngine.getSignalCount(runID) > 0)
            b = true;
            break;
        end
    end
else
    runs = h.simruns.keySet.toArray;
    for i = 1:length(runs)
        if ~h.simruns.get(runs(i)).get('blocks').isEmpty
            b = true;
            break;
        end
    end
end


% [EOF]
