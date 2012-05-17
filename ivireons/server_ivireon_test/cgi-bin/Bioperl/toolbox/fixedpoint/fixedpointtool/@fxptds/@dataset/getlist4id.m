function list = getlist4id(h, run, id)
% GETLIST4ID  get the LIST for specified ID in the specified RUN

%   Author(s): G. Taillefer
%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/04/05 22:16:34 $

if(~isequal(3, nargin) || ~isnumeric(run)  || isempty(run) || isempty(id) || ~ischar(id))
  error('fixedpoint:fxptds:dataset:setlist4id:inValidInputArgs', ...
        'Invalid or not enough input arguments.\nPlease specify RUN (double), ID (char).');
end

if h.isSDIEnabled
    runID = h.getRunID(run);
    runDataMaps = h.RunDataMap.getDataByKey(runID);
    list4id = runDataMaps.getDataByKey('list4id').getDataByKey(id);
    % initialize the list array for improved performance. Initialize them
    % with fxptui.simresult as they are most common.
    list(1:length(list4id)) = fxptui.simresult;
    cntr = 1;
    for i = 1:length(list4id)
        % This is to protect against entries in the list that are hidden
        % blocks. They are not removed when the model compilation is
        % terminated.  The result is removed from the dataset mysteriously,
        % but not from the lists.
        if isa(list4id(i),'fxptui.abstractresult') && isa(list4id(i).daobject,'DAStudio.Object')
            list(cntr) = list4id(i);
            cntr = cntr+1;
        end
    end
else
    jlist = h.simruns.get(run).get('list4id').get(id);
    % initialize the list array for improved performance. Initialize them
    % with fxptui.simresult as they are most common.
    if ~isempty(jlist)
        list(1:numel(jlist)) = fxptui.simresult;
    else
        list = [];
        return;
    end
    cntr = 1;
    for idx = 1:numel(jlist)
        hjlist = handle(jlist(idx));
        % This is to protect against entried in the list that are hidden
        % blocks. They are not removed when the model compilation is
        % terminated.  The result is removed from the dataset mysteriously,
        % but not from the lists.
        if ~isempty(hjlist) && isa(hjlist.daobject,'DAStudio.Object')
            list(cntr) = hjlist;
            cntr = cntr+1;
        end
    end
end

%Delete excess memory locations.
list(cntr:end) = [];


% [EOF]
