function [difficulty, scheduler, numTasks, networkDir] = pctdemo_helper_getDefaults()
%PCTDEMO_HELPER_GETDEFAULTS Process the settings in PARALLELDEMOCONFIG.
%   PCTDEMO_HELPER_GETDEFAULTS reads the configuration from
%   defaultParallelConfig and other settings from PARALLELDEMOCONFIG, fills in
%   default values and performs error checking.
%   
%   difficulty = pctdemo_helper_getDefaults() returns the default demo  
%   difficulty level.
%   
%   [difficulty, scheduler] = pctdemo_helper_getDefaults()
%   uses the default configuration with findResource to find a scheduler and
%   returns a scheduler object in addition to the demo difficulty level.
%   
%   [difficulty, scheduler, numTasks] = pctdemo_helper_getDefaults() also 
%   makes sure we have a sensible value for the number of tasks. 
%   
%   [difficulty, scheduler, numTasks, networkDir] = pctdemo_helper_getDefaults()
%   also returns the network directory for reading/saving temporary files.
%   
%   See also defaultParallelConfig, PARALLELDEMOCONFIG, findResource

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/05/05 21:37:15 $

    config = paralleldemoconfig();

    % Get the demo difficulty level.
    difficulty = config.Difficulty;
    
    if (nargout <= 1)
        % If we are not asked to return a scheduler object, return now.  This
        % allows the users to run the sequential demos even when there is no 
        % scheduler available to us.
        return;
    end
    
    % Get the jobmanager object.
    try
        scheduler = iGetScheduler();
    catch err
        rethrow(err);
    end
    % We now have a valid scheduler object.
    
    numTasks = config.NumTasks;
    % Get the shared network directory.
    networkDir = config.NetworkDir;
end % End of pctdemo_helper_getDefaults.


function scheduler = iGetScheduler()
% Tries to return a scheduler object.  Errors in case of failure.
    configuration = defaultParallelConfig();
    try
        % We put the configuration at the end so that it overrides the 
        % default, which is to find a job manager.
        scheduler = findResource('scheduler', 'Configuration', configuration);
    catch err
        errorDesc = sprintf(['An error occurred when using the ', ...
            'findResource command.  The error message\n', ...
            'received from findResource was:\n%s\n'], ...
            err.message);
        iSchedulerError(errorDesc);
    end
    
    if (numel(scheduler) > 1)
        errorDesc = sprintf('Found %d schedulers', numel(scheduler));
        iSchedulerError(errorDesc);
    end
    if isempty(scheduler)
        errorDesc = sprintf('No scheduler found.');
        iSchedulerError(errorDesc);
    end
    set(scheduler, 'Configuration', configuration);

    % Validates that number of workers is > 0 and the state is running.
   iValidateIfJobmanager(scheduler); 
end % End of iGetScheduler.

function iSchedulerError(errorMessage)
% Throws an error with a detailed message if we can't find a scheduler or if
% the job manager does not have any workers attached to it.
    
    error('distcomp:demo:NoScheduler', ...
          ['Could not find an appropriate scheduler for the following reason:\n' ...
           '\n' ...
           '%s\n' ...
           '\n' ...
           'See the section "Programming with User Configurations" in the documentation\n' ...
           'for how to set the default configuration and modify its values.'], ...
          errorMessage);
end % End of iSchedulerError.
    
function iValidateIfJobmanager(manager)
%If given a job manager: Throws an error if it does not have at least one worker
%attached to it and is not in the running state.
    if ~isa(manager, 'distcomp.jobmanager')
        return;
    end
    if ~strcmpi(manager.State, 'running')
        errorDesc = sprintf(['The job manager ''%s'' is not in the running ', ...
            'state.'], manager.Name);
        iSchedulerError(errorDesc);
    end
    numWorkers = manager.NumberOfBusyWorkers + manager.NumberOfIdleWorkers;
    if (numWorkers == 0)
        errorDesc = sprintf(['The job manager ''%s'' does not have any ', ...
            'workers attached to it.'], manager.Name);
        iSchedulerError(errorDesc);
    end
end % End of iValidateIfJobmanager.
