function data = getAllOutputArguments(job)
%getAllOutputArguments  Retrieve outputs from first task of a matlabpool job
%
%    data = getAllOutputArguments(obj) returns the output data contained
%    in the first task of a finished matlabpool job. The output is a
%    1-by-N cell array. The N elements are arrays containing the output
%    arguments from the job's first task.
%    
%    Note that issuing a call to getAllOutputArguments will not remove the
%    output data from the location where it is stored. To remove the output
%    data, use the destroy function to remove the individual task or their
%    parent job object.
%    
%    Example:
%    % Create a matlabpool job to generate a random matrix.
%    jm = findResource('scheduler', 'type', 'local', ...
%                      'LookupURL', 'JobMgrHost');
%    j = createMatlabPoolJob(jm, 'Name', 'myjob');
%    t = createTask(j, @rand, 1, {10});
%    submit(j);
%    % Wait until the job is finished.
%    waitForState(j, 'finished');
%    % Get the random matrix.
%    data = getAllOutputArguments(j);

%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2008/10/02 18:40:47 $

% Ensure that only one job has been passed in
if numel(job) > 1
    error('distcomp:simplematlabpooljob:InvalidArgument', ...
          'The function GetAllOutputArguments requires a single job input');
end
% Get all the tasks from this job
task = job.Task;
if isempty(task)
    error('distcomp:simplematlabpooljob:TaskError', ...
          'No task has been created so far.');
end
% Create a cell array to hold the output
data = cell(1, 0);
% Just get the first task's output
% We want to get the output arguments, any errors should be rethrown
out = task.pGetOutputArguments({}, true);
% Need to deal with the case where the function call has 0 output
% arguments and returns a {} rather than cell(1, 0)
if ~isempty(out)
    data(1, 1:length(out)) = out;
end
