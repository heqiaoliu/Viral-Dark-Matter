function val = pGetOutputArguments(task, val, RETHROW_ERROR)
; %#ok Undocumented
%PGETOUTPUTARGUMENTS A short description of the function
%
%  VAL = PGETOUTPUTARGUMENTS(TASK, VAL)

%  Copyright 2000-2008 The MathWorks, Inc.

%  $Revision: 1.1.8.8 $    $Date: 2008/09/13 06:51:41 $ 

if nargin < 3
    RETHROW_ERROR = false;
end

proxyTask = task.ProxyObject;
try
    dataItem = proxyTask.getOutputData(task.UUID);    
    data = dataItem(1).getData;
    if ~isempty(data) && data.limit > 0
        val = distcompdeserialize(data);
    else
        val = cell(1, 0);
    end
    dataItem(1).delete();
catch err
    if RETHROW_ERROR
        rethrow(err)
    end
    distcomp.handleGetLargeDataError(task, err);
    % This method must return a cell array.
    val = cell(1, 0);
end
