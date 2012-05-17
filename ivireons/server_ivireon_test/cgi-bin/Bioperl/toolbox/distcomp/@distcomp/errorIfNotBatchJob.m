function errorIfNotBatchJob(job)
; %#ok Undocumented

%  Copyright 2007 The MathWorks, Inc.

% $Revision: 1.1.6.2 $  $Date: 2007/12/10 21:27:50 $

if numel(job) > 1
    error('distcomp:batch:TooManyJobs', 'Batch commands are not supported on multiple jobs');
end

task = get(job, 'Tasks');

if isempty(task) || ~strcmp(job.Tag, 'Created_by_batch') || ( ~job.pIsMatlabPoolJob && numel(job.Tasks) > 1 )
    error('distcomp:batch:NotBatchJob', 'Batch commands are only supported on jobs created with the ''batch'' command');
end

