function val = pGetFunction(task, val)
; %#ok Undocumented
%PGETFUNCTION A short description of the function
%
%  VAL = PGETFUNCTION(TASK, VAL)

%  Copyright 2000-2008 The MathWorks, Inc.

%  $Revision: 1.1.8.8 $    $Date: 2008/09/13 06:51:39 $ 

proxyTask = task.ProxyObject;
try
    dataItem = proxyTask.getMLFunction(task.UUID);
    data = dataItem(1).getData;
    if ~isempty(data) && data.limit > 0
        val = distcompdeserialize(data);
    else
        val = [];
    end
    dataItem(1).delete();
catch err
    distcomp.handleGetLargeDataError(task, err);
end
