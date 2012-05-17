function setlist4id(h, run, id, list)
% SETLIST4ID  sets LIST for specified ID in the specified RUN

%   Author(s): G. Taillefer
%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/04/05 22:16:47 $

if(~isequal(4, nargin) || ~isnumeric(run) || isempty(run) || ~isvarname(id) || isempty(list))
  error('fixedpoint:fxptds:dataset:setlist4id:inValidInputArgs', ...
        'Invalid or not enough input arguments.\nPlease specify RUN (double), ID (varname) and LIST ([results]).');
end
if  h.isSDIEnabled
    runID = getRunID(h,run);
    runDataMaps = h.RunDataMap.getDataByKey(runID);
    % list4idMap is a Data Map.
    list4idMap = runDataMaps.getDataByKey('list4id');
    list4idMap.insert(id,list);
else
    list4idHash = h.simruns.get(run).get('list4id');
    %udd objects need bean adaptors in order to be stored in hash tables
    jlist = java(list);
    list4idHash.put(id, jlist);
end

% [EOF]
