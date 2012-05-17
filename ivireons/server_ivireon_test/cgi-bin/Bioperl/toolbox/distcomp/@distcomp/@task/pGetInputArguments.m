function val = pGetInputArguments(task, val)
; %#ok Undocumented
%PGETINPUTARGUMENTS A short description of the function
%
%  VAL = PGETINPUTARGUMENTS(TASK, VAL)

%  Copyright 2000-2008 The MathWorks, Inc.

%  $Revision: 1.1.8.8 $    $Date: 2008/09/13 06:51:40 $ 

proxyTask = task.ProxyObject;
try
    dataItem = proxyTask.getInputData(task.UUID);
    data = dataItem(1).getData;
    if ~isempty(data) && data.limit > 0
        val = distcompdeserialize(data);
    else
        val = cell(1, 0);
    end
    dataItem(1).delete();
catch err
    distcomp.handleGetLargeDataError(task, err);
    % This method must return a cell array.
    val = cell(1, 0);
end
