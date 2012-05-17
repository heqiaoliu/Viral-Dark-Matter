function data = getAllOutputArguments(job)
; %#ok Undocumented
%getAllOutputArguments  Retrieve outputs from all tasks in a job object
%
% data = getAllOutputArguments(obj) returns data, the output data contained
% in the tasks of a finished job. If the job has M tasks, each row of the
% M-by-N cell array data contains the output arguments for the corresponding
% task in the job. Each row has N columns, where N is the greatest number of
% output arguments from any one task in the job. The N elements of a row are
% arrays containing the output arguments from that task. If a task has less than
% N output arguments, the excess arrays in the row for that task are empty. The
% order of the rows in data will be the same as the order of the tasks contained
% in the job.
%
% Note that issuing a call to getAllOutputArguments will not remove the output
% data from the location where it is stored. To remove the output data, use the
% destroy function to remove the individual task or their parent job object.
%
% Example:
%     jm = findResource('jobmanager');
%     j = createJob(jm, 'Name', 'myjob');
%     t = createTask(j, @rand, 1, {10});
%     submit(j);
%     data = getAllOutputArguments(j);
%

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.4 $    $Date: 2008/02/02 12:59:37 $

% Ensure that only one job has been passed in
if numel(job) > 1
    error('distcomp:job:InvalidArgument', 'The function GetAllOutputArguments requires a single job input');
end
% Get all the tasks from this job
tasks = job.Tasks(:);
% Create a cell array to hold the output
data = cell(numel(tasks), 0);
% Loop over each task an get the output
for i = 1:numel(tasks)
    % We want to get the output arguments by any errors should be rethrown
    out = tasks(i).pGetOutputArguments({}, true);
    % Need to deal with the case where the function call has 0 output
    % arguments and returns a {} rather than cell(1, 0)
    if ~isempty(out)
        data(i, 1:length(out)) = out;
    end
end