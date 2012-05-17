function val = pSetMinimumNumberOfWorkers(job, val, doValueCheck, currentMax)
; %#ok Undocumented
%PSETMINIMUMNUMBEROFWORKERS A short description of the function
%
%  VAL = PSETMINIMUMNUMBEROFWORKERS(JOB, VAL, doValueCheck)
%
% Some internal functions within the API will want to set min
% workers without checking the value of min, as they are setting min
% at the same time.

%  Copyright 2000-2008 The MathWorks, Inc.

%  $Revision: 1.1.8.7 $    $Date: 2008/08/26 18:13:25 $ 

if val < 0 || val ~= round( val )
    error('distcomp:job:InvalidProperty', 'MinimumNumberOfWorkers must be a non-negative integer');
end

% Get INTMAX for int32 to check for Inf
INTMAX_I32 = intmax('int32');
% Convert to an int32
if ~isfinite(val) || val > INTMAX_I32
    val = INTMAX_I32;
else
    val = int32(val);
end
if val == INTMAX_I32
    error('distcomp:job:InvalidProperty', 'MinimumNumberOfWorkers must be the same as or less than MaximumNumberOfWorkers for a job');    
end

% If we are being constructed or configured we are going to delay the setting
% of Max and Min until the end to ensure we can check the consistency of the values
if job.IsBeingConstructed || job.IsBeingConfigured 
    postFcn  = @pSetMaxAndMinNumberOfWorkers;
    % Use different post-behaviour depending on if we are being constructed or
    % configured. NOTE if we are being both constructed and configured use
    % the post construction behaviour
    if job.IsBeingConstructed        
        findFcn = @pFindPostConstructionFcn;
        addFcn  = @pAddPostConstructionFcn;
    else
        findFcn = @pFindPostConfigurationFcn;
        addFcn  = @pAddPostConfigurationFcn;
    end
    % Have we already set this post construction function once?
    [index, oldMin, oldMax, oldFirst] = findFcn(job, postFcn);
    % Not set already - then get the oldMax
    if isempty(index)
        oldMax = job.MaximumNumberOfWorkers;
    end
    % Add (or overwrite) the old post construction function
    addFcn(job, postFcn, val, oldMax, 'min');
    val = 0;
    return
end

if nargin < 3
    doValueCheck = true;
end
if doValueCheck && nargin < 4
    currentMax = job.MaximumNumberOfWorkers;
end
    
proxyJob = job.ProxyObject;
if ~isempty(proxyJob)  
    % Only check the input value if doValueCheck is true
    if doValueCheck && val > currentMax 
        error('distcomp:job:InvalidProperty', ...
            'MinimumNumberOfWorkers must be the same as or less than MaximumNumberOfWorkers for a job');
    end

    try
        proxyJob.setMinWorkers(job.UUID, val);
    catch err    
        throw(distcomp.handleJavaException(job, err));
    end
end
% Do not hold anything locally
val = 0;
