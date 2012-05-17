function clearlists4allids(h, run)
% CLEARLIST4ID clears all id to list mappings for specified RUN

%   Author(s): G. Taillefer
%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/04/05 22:16:25 $

if(~isequal(2, nargin) || ~isnumeric(run) || isempty(run))
  error('fixedpoint:fxptds:dataset:setlist4id:inValidInputArgs', ...
        'Invalid or not enough input arguments. Please specify RUN (double)');
end
if h.isSDIEnabled
    runID = h.getRunID(run);
    runDataMaps = h.RunDataMap.getDataByKey(runID);
    runDataMaps.getDataByKey('list4id').Clear;
else
    runHash = h.simruns.get(run);
    % In some situations where the FPT is launched via the FPA, we can come
    % across a situation where the FPT callbacks attempt to operate on a run
    % before the run is initialized. We need to protect against such cases.
    if ~isempty(runHash)
        runHash.get('list4id').clear;
    end
end

% [EOF]
