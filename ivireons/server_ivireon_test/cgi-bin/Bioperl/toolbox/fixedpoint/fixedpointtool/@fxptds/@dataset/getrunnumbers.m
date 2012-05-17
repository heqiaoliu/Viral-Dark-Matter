function runs = getrunnumbers(h)
% GETRUNNUMBERS  returns the run numbers in dataset that contains results.
%   RUNS = GETRUNNUMBERS(H) returns a 1xN array of run numbers
%   present in H

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2010/04/05 22:16:38 $

if h.isSDIEnabled
    % get the run numbers that were created in the dataset.
    runs = [];
    for i = 1:h.RunIDMap.getCount
        % Get the runID that was returned by the SDI while creating a run
        % for runStr.
        runID = h.RunIDMap.getDataByIndex(i);
        if (h.SDIEngine.getSignalCount(runID) > 0)
            % Convert the string to a run number before adding it to runs.
            runNumber = fxptui.str2run(h.RunIDMap.getKeyByIndex(i));
            runs = [runs runNumber]; %#ok
        end
    end
else
    %get the java array of run numbers (may be non-contiguous)
    jRuns = h.simruns.keySet.toArray;
    runs = [];
    %construct a MATLAB vector of run numbers
    for i = 1:jRuns.length
        run = jRuns(i);
        %get the run hash
        runHash = h.simruns.get(run);
        %get the hash containing blocks as keys
        allblocksHash = runHash.get('blocks');
        hasMetadata = runHash.get('metadata').size > 0;
        if(isempty(allblocksHash) && ~hasMetadata); continue; end
        blocks = allblocksHash.keySet.toArray;
        if(~isempty(blocks) || hasMetadata)
            runs = [runs run]; %#ok<AGROW>
        end
    end
end
%might as well return them in the right order
runs = sort(runs);

% [EOF]
