function [numRuns, numSignals] = getrecordcount(h)
%GETRECORDCOUNT Get the recordcount.

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/04/05 22:16:36 $

runNumbers = h.getrunnumbers;
%get the run numbers. these are prepopulated in init
numRuns = length(runNumbers);
%initialize number of signals
numSignals = 0;
if h.isSDIEnabled
   for i = runNumbers
       runID = getRunID(h,i);
       if isempty(runID); continue; end;
       numSignals = numSignals + h.SDIEngine.getSignalCount(runID);
   end
else
    for i = 1:numRuns
        %get the run hash
        runHash = h.simruns.get(runNumbers(i));
        %get the hash containing blocks as keys
        blocksHash = runHash.get('blocks');
        blk_keys = blocksHash.keySet.toArray;
        for blkIdx = 1:length(blk_keys)
            blkHash = blocksHash.get(blk_keys(blkIdx));
            if(isempty(blkHash)); continue ;end
            %add the number of signals from this run to the total
            numSignals = numSignals + blkHash.size;
        end
        
    end
end
% [EOF]
