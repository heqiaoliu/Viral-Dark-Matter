function val = pGetCommandWindowOutput(task, val)
; %#ok Undocumented
%PGETCOMMANDWINDOWOUTPUT A short description of the function
%
%  VAL = PGETCOMMANDWINDOWOUTPUT(TASK, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.5 $    $Date: 2008/10/02 18:40:50 $ 

proxyTask = task.ProxyObject;
try
    dataItem = proxyTask.getCommandWindowOutput(task.UUID);
    data = dataItem(1).getData();
    if ~isempty(data) && data.limit > 0
        val = distcompdeserialize(data);
    else
        val = '';
    end
    dataItem(1).delete();
catch err
    distcomp.handleGetLargeDataError(task, err);
    val = '';
end
