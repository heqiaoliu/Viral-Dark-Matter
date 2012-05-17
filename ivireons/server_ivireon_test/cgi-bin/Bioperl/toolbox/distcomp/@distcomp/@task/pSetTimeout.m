function val = pSetTimeout(task, val)
; %#ok Undocumented
%PSETTIMEOUT A short description of the function
%
%  VAL = PSETTIMEOUT(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2008/02/02 13:01:19 $ 


if val < 0
    error('distcomp:task:InvalidProperty', 'Timeout must be zero or greater');
end
% convert to milliseconds
val = val * 1000; 
% Get INTMAX for int64 to check for Inf
INTMAX_I64 = intmax('int64');

if ~isfinite(val) || val > INTMAX_I64
    val = INTMAX_I64;
else
    val = int64(val);
end

try
    if ~isempty(task.TaskInfo)
        task.TaskInfo.setTimeout(val);
    elseif task.HasProxyObject
        task.ProxyObject.setTimeout(task.UUID, val);
    end
catch err
    throw(distcomp.handleJavaException(task, err));
end    
% Do not hold anything locally
val = 0;