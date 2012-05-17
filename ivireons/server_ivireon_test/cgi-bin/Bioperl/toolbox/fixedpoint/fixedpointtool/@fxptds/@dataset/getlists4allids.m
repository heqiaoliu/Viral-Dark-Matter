function s = getlists4allids(h, run)
% GETALLLISTS  returns a struct containing fields for each list id assigned
% with a vector of results 

%   Author(s): G. Taillefer
%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/04/05 22:16:35 $

s = [];
if(~isequal(2, nargin) || ~isnumeric(run)  || isempty(run))
  error('fixedpoint:fxptds:dataset:setlist4id:inValidInputArgs', ...
        'Invalid or not enough input arguments.\nPlease specify RUN (double).');
end
if h.isSDIEnabled
    runID = h.getRunID(run);
    runDataMaps = h.RunDataMap.getDataByKey(runID);
    % list4idMap is a Data Map.
    list4idMap = runDataMaps.getDataByKey('list4id');
    for i = 1:list4idMap.getCount
        id = list4idMap.getKeyByIndex(i);
        s.(id) = h.getlist4id(run,id);
    end
else
    list4idHash = h.simruns.get(run).get('list4id');
    keys = list4idHash.keySet.toArray;
    for idx = 1:numel(keys)
        id = keys(idx);
        s.(id) = h.getlist4id(run, id);
    end
end
% [EOF]
