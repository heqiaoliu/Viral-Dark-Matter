function val = pSetMaximumNumberOfWorkers(job, val, doValueCheck, currentMin)
; %#ok Undocumented
%PSETMAXIMUMNUMBEROFWORKERS A short description of the function
%
%  VAL = PSETMAXIMUMNUMBEROFWORKERS(JOB, VAL, doValueCheck)
%
% Some internal functions within the API will want to set max
% workers without checking the value of min, as they are setting min
% at the same time.

%  Copyright 2000-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.5 $    $Date: 2008/08/26 18:13:42 $ 

if val < 0 || val ~= round( val )
    error('distcomp:job:InvalidProperty', 'MaximumNumberOfWorkers must be a non-negative integer');
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
    % Not set already - then get the oldMin
    if isempty(index)
        oldMin = job.MinimumNumberOfWorkers;
    end
    % Add (or overwrite) the old post construction function
    addFcn(job, postFcn, oldMin, val, 'max');
    val = 0;
    return
end

if nargin < 3
    doValueCheck = true;
end
if doValueCheck && nargin < 4
    currentMin = job.MinimumNumberOfWorkers;
end

serializer = job.Serializer;
if ~isempty(serializer)
    % Only check the input value if doValueCheck is true
    if doValueCheck && val < currentMin
        error('distcomp:job:InvalidProperty', ...
              'MaximumNumberOfWorkers must be the same as or greater than the MinimumNumberOfWorkers for a job');
    end

    try
        serializer.putField(job, 'maxworkers', val);
    end
end
% Do not hold anything locally
val = 0;