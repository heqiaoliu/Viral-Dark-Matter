function setblklist4src(h,run,src,list)
% SETBLKLIST4SRC sets the list of blocks for a specified actual src and run.

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/04/05 22:16:46 $

if(~isequal(4, nargin) || ~isnumeric(run) || isempty(run) || isempty(list))
  error('fixedpoint:fxptds:dataset:setblklist4src:inValidInputArgs', ...
        'Invalid or not enough input arguments.\nPlease specify RUN (double), SRC (blk object) and LIST ([results]).');
end

if h.isSDIEnabled
    runID = getRunID(h,run);
    runDataMaps = h.RunDataMap.getDataByKey(runID);
    % blklist4src is a java hash map.
    blklist4srcJHashMap = runDataMaps.getDataByKey('blklist4src');
else
    blklist4srcJHashMap = h.simruns.get(run).get('blklist4src');
end

%udd objects need bean adaptors in order to be stored in hash tables
jlist = java(list);
blklist4srcJHashMap.put(src, jlist);



% [EOF]
