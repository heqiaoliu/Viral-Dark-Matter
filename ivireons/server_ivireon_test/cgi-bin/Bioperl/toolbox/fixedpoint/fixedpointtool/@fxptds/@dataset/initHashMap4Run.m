function initHashMap4Run(h,run)
% Initializes the hashmap in the dataset for a particular run.

%   Author(s): V. Srinivasan
%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/04/05 22:16:41 $

if h.isSDIEnabled
    runStr = fxptui.run2str(run);
    % If the run doesn't exist, create one.
    if ~h.RunIDMap.isKey(runStr);    
        runID = h.SDIEngine.createRun(runStr);
        % Put the run number returned by the SDI Engine in the map.
        h.RunIDMap.insert(runStr, runID);
        addMetaDataToRun(h, runID);
    end
else
    runHash = java.util.LinkedHashMap;     
    h.simruns.put(run, runHash);
    runHash.put('metadata', java.util.LinkedHashMap);
    runHash.put('blocks', java.util.LinkedHashMap);
    runHash.put('list4id', java.util.LinkedHashMap);
    runHash.put('blklist4src', java.util.LinkedHashMap);
end

%-------------------------------------------

%[EOF]
