function poolStartup
% POOLSTARTUP Perform user-specific pool startup actions.
%
%   poolStartup
%
%   To define specific initialization actions on each worker just after the
%   pool has been instantiated you can do any of the following:
%   1. Add MATLAB code that performs those actions to this file for each
%      worker.
%   2. Add to the job's PathDependencies property a directory that
%      contains a file named poolStartup.m.
%   3. Include a file named poolStartup.m in the job's FileDependencies
%      property.
%
%   The file in FileDependencies takes precendence over the
%   PathDependencies file, which takes precedence over this file on
%   the worker's installation.
%
%   If poolStartup throws an error, the error information appears in the
%   task's ErrorMessage and ErrorIdentifier properties, and the task will
%   not be executed.
%
%   Any path changes made here or during the execution of tasks will be
%   reverted by the MATLAB Distributed Computing Server to their original
%   values before the next job runs. However any path changes in this file
%   will not be used to distinguish the task function as it will have been
%   loaded before this function is executed.
%
%   See also jobStartup, taskStartup.

% Copyright 2009-2010 The MathWorks, Inc.

