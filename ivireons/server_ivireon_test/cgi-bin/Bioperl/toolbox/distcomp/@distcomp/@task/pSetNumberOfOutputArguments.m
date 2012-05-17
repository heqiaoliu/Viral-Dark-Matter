function val = pSetNumberOfOutputArguments(task, val)
; %#ok Undocumented
%PSETNUMBEROFOUTPUTARGUMENTS A short description of the function
%
%  VAL = PSETNUMBEROFOUTPUTARGUMENTS(TASK, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2008/02/02 13:01:18 $ 

if val < 0
    error('distcomp:task:InvalidProperty', 'NumberOfOutputArguments must be a non-negative integer');
end

try
    if ~isempty(task.TaskInfo)
        task.TaskInfo.setNumOutArgs(val);
    elseif task.HasProxyObject
        task.ProxyObject.setNumOutArgs(task.UUID, val);
    end
catch err
    throw(distcomp.handleJavaException(task, err));
end    
% Do not hold anything locally
val = 0;