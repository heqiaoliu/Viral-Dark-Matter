function cleanuprun(h, run)
%CLEANUPRUN(RUN, RUNTIME) remove old blocks that weren't updated for the
% specified run during the specified runtime

%   Author(s): G. Taillefer
%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2010/04/05 22:16:22 $

allResults = h.getresults(run);
if  h.isSDIEnabled
    runID = h.getRunID(run);
    runtime = h.SDIEngine.getDateCreated(runID);
else
    runtime = h.getmetadata(run, 'RunTime');
end
h.clearlists4allids(run);
%loop through the results looking for stale results (not updated during
%last run
for i = 1:numel(allResults)
    thisResult = allResults(i);
    %make sure we haven't already deleted the result for a given block.
    %clearresults will clear multiple results for a given block (ex: dspblks
    %multiple outputs)
    if(isa(thisResult, 'fxptui.abstractresult'))
        if(~isequal(runtime, thisResult.RunTime))
            h.clearresults(run, thisResult);
        end
    end
end
% [EOF]
