function ctors = pGetUDDConstructorsForJobTypes(jm, jobTypes) %#ok<INUSL>
; %#ok Undocumented
%pGetUDDConstructorsForJobTypes Return the correct constructors for jobs

% Copyright 2005-2007 The MathWorks, Inc.

% $Revision: 1.1.10.3 $    $Date: 2007/10/10 20:41:05 $

persistent STANDARD_JOB_TYPE;
persistent PARALLEL_JOB_TYPE;
persistent MATLABPOOL_JOB_TYPE;

if isempty(STANDARD_JOB_TYPE)    
    import com.mathworks.toolbox.distcomp.workunit.JobMLType;
    STANDARD_JOB_TYPE = JobMLType.STANDARD_JOB;
    PARALLEL_JOB_TYPE = JobMLType.PARALLEL_JOB;
    MATLABPOOL_JOB_TYPE = JobMLType.MATLABPOOL_JOB;
end

% Deal with the empty input first
if isempty(jobTypes)
    ctors = {};
    return
end

% Check if all jobTypes are identical
if all(jobTypes == jobTypes(1))
    % Return a single constructor in this case
    jobTypes = jobTypes(1);
end

numJobs = numel(jobTypes);
% Construct the output cell array
ctors = cell(numJobs, 1);

for i = 1:numJobs
    switch jobTypes(i)
        case STANDARD_JOB_TYPE
            ctors{i} = @distcomp.job;
        case PARALLEL_JOB_TYPE
            ctors{i} = @distcomp.paralleljob;
        case MATLABPOOL_JOB_TYPE
            ctors{i} = @distcomp.matlabpooljob;
        otherwise
    end
end

% Unwrap the single output
if numJobs == 1
    ctors = ctors{1};
end
