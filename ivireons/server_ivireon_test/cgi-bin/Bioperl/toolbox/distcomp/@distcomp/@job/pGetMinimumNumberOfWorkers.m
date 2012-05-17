function val = pGetMinimumNumberOfWorkers(job, val)
; %#ok Undocumented
%PGETMINIMUMNUMBEROFWORKERS A short description of the function
%
%  VAL = PGETMINIMUMNUMBEROFWORKERS(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.4 $    $Date: 2006/06/27 22:36:54 $ 

proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
    try
        iVal = proxyJob.getMinWorkers(job.UUID);
        % Check if the number is INTMAX for int32
        if isequal(iVal, intmax('int32'))
            val = Inf;
        else
            val = double(iVal);
        end
    end
end