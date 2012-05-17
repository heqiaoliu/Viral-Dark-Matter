function s = getallids(h, run)
% GETALLIDS  returns a struct containing fields for each list id
% with a vector of results 

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2010/04/05 22:16:32 $

if h.isSDIEnabled
    runID = h.getRunID(run);
    runDataMaps = h.RundataMap.getDataByKey(runID);
    list4idMap = runDataMaps.getDataByKey('list4id');
    s(1:list4idMap.getCount) = {''};
    for i = 1:list4idMap.getCount
        s{i} = list4idMap.getKeyByIndex(i);
    end
else
    list4idHash = h.simruns.get(run).get('list4id');
    keys = list4idHash.keySet.toArray;
    s = cell(size(keys));
    for idx = 1:numel(keys)
        s{idx} = keys(idx);
    end
end

% [EOF]
