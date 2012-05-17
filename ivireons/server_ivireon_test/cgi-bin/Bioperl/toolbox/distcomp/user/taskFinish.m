function taskFinish(task)
% TASKFINISH Perform user-specific task cleanup actions.
%
%   taskFinish(task)
%
%   To define specific task cleanup actions on each worker
%   for each task, you can do any of the following:
%   1. Add MATLAB code that performs those actions to this file for each
%      worker.
%   2. Add to the job's PathDependencies property a directory that
%      contains a file named taskFinish.m.
%   3. Include a file named taskFinish.m in the job's FileDependencies
%      property.
%
%   The file in FileDependencies takes precendence over the
%   PathDependencies file, which takes precedence over this file on
%   the worker's installation.
%
%   The task parameter that is passed to this function is the task object
%   that the worker has just executed.
%
%   This function runs even if the jobStartup, taskStartup, or the
%   task itself threw an error.
%
%   If this function throws an error, the error information appears in the task's
%   ErrorMessage and ErrorIdentifier properties unless the jobStartup,
%   taskStartup, or the task itself threw an error.
%
%   Any path changes made here or during the execution of tasks will be
%   reverted by the MATLAB Distributed Computing Server to their original
%   values before the next job runs, but preserved for subsequent tasks in
%   the same job.  Any data stored by this function or by the execution of
%   the job's tasks (for example, in the base workspace or in global or
%   persistent variables) will not be cleared by the MATLAB Distributed
%   Computing Server before the next job runs, unless the RestartWorker
%   property of the next job is set to true.
%
%   See also jobStartup, taskStartup.

% Copyright 2004-2010 The MathWorks, Inc.
