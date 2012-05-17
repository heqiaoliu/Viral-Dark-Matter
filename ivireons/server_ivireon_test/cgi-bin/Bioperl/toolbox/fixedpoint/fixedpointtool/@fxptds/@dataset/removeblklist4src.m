function removeblklist4src(h,src,varargin)
% REMOVEBLKLIST4SRC  removes SRC to LIST mapping for specified RUN and returns
% the list
%
%   Author(s): V.Srinivasan
%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/04/05 22:16:43 $

if ((nargin < 2) || isempty(src))
  error('fixedpoint:fxptds:dataset:removeblklist4src:inValidInputArgs', ...
        'Invalid or not enough input arguments.\nPlease specify SRC (blk object).');
end

if nargin == 3
    run = varargin{1};
else
    run = [0 1];
end

if h.isSDIEnabled
    for i = 1:numel(run)
        runID = h.getRunID(run(i));
        if ~isempty(runID)
            if isKey(h.RunDataMap, runID)
                runDataMaps = h.RunDataMap.getDataByKey(runID);
                % blklist4src is a Java HashMap.
                runDataMaps.getDataByKey('blklist4src').remove(src);
            end
        end
    end
else
    for i = 1:numel(run)
        h.simruns.get(run(i)).get('blklist4src').remove(src);
    end
end

% [EOF]
