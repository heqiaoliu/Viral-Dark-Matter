function clearblklist4allsrc(h,run)
% CLEARBLKLIST4ALLSRC clears all src to list mappings for specified RUN

%   Author(s): V.Srinivasan
%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/04/05 22:16:23 $

if(~isequal(2, nargin) || ~isnumeric(run) || isempty(run))
  error('fixedpoint:fxptds:dataset:setlist4id:inValidInputArgs', ...
        'Invalid or not enough input arguments. Please specify RUN (double)');
end
if  h.isSDIEnabled
    runID = h.getRunID(run);
    runDataMaps = h.RunDataMap.getDataByKey(runID);
    runDataMaps.getDataByKey('blklist4src').clear;
else
    h.simruns.get(run).get('blklist4src').clear;
end

% [EOF]
