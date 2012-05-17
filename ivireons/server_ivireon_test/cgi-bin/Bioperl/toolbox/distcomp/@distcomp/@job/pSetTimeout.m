function val = pSetTimeout(job, val)
; %#ok Undocumented
%PSETTIMEOUT A short description of the function
%
%  VAL = PSETTIMEOUT(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.5 $    $Date: 2008/02/02 13:00:06 $ 

proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
    if val < 0
        error('distcomp:job:InvalidProperty', 'Timeout must be zero or greater');
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
        proxyJob.setTimeout(job.UUID, val); 
	catch err
    	throw(distcomp.handleJavaException(job, err));
    end
end
% Do not hold anything locally
val = 0;
