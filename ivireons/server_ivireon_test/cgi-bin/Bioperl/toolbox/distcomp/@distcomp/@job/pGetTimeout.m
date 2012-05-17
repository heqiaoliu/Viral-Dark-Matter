function val = pGetTimeout(job, val)
; %#ok Undocumented
%PGETTIMEOUT A short description of the function
%
%  VAL = PGETTIMEOUT(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.4 $    $Date: 2006/06/27 22:37:04 $ 

proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
    try
        lVal = proxyJob.getTimeout(job.UUID);
        % Check if the number is INTMAX for int64
        if isequal(lVal, intmax('int64'))
            val = Inf;
        else
            val = double(lVal) / 1000; % convert to seconds
        end
    end
end