function runID = getRunID(h, runStr)
%GETRUN4ID Get the run ID that was used to create the run.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/04/05 22:16:30 $

if ~ischar(runStr)
    runStr = fxptui.run2str(runStr);
end
% return runID if it exists. Otherwise return empty.
if h.RunIDMap.isKey(runStr)
    runID = h.RunIDMap.getDataByKey(runStr);
else
    runID = [];
end

% [EOF]
