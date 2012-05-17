function varargout = removelist4id(h, run, id)
% REMOVELIST4ID  removes ID to LIST mapping for specified RUN and returns
% the list

%   Author(s): G. Taillefer
%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/04/05 22:16:44 $

if(~isequal(3, nargin) || ~isnumeric(run) || isempty(run))
  error('fixedpoint:fxptds:dataset:setlist4id:inValidInputArgs', ...
        'Invalid or not enough input arguments.\nPlease specify RUN (double), ID (char).');
end

if h.isSDIEnabled
    runID = h.getRunID(run);
    runDataMaps = h.RunDataMap.getDataByKey(runID);
    if nargout == 1
        % List is a Data Map.
        list = runDataMaps.getDataByKey('list4id').getDataByKey(id);
        varargout = {list};
    end
    list4IDMap = runDataMaps.getDataByKey('list4id');
    if isKey(list4IDMap, id)
        list4IDMap.deleteDataByKey(id);
    end
else
    jlist = h.simruns.get(run).get('list4id').remove(id);
    %initialize the list array for improved performance. Use fxptui.simresult as they are most common.
    % return the list only if we have an LHS when this method is called. This is done to improve performance.
    if nargout == 1
        if ~isempty(jlist)
            list(1:numel(jlist)) = fxptui.simresult;
        else
            list = [];
        end
        for idx = 1:numel(jlist)
            list(idx) = handle(jlist(idx));
        end
        varargout = {list};
    end
end


% [EOF]
