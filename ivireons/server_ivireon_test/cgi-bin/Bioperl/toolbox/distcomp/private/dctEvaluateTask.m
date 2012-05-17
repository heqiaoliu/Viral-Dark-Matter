function dctEvaluateTask(postFcns, finishFcn)
% This function is used to evaluate a task from any scheduler

%  Copyright 2006-2009 The MathWorks, Inc.

%  $Revision: 1.1.6.20 $    $Date: 2009/12/03 19:00:34 $


% Get the job and task objects
root = distcomp.getdistcompobjectroot;
job = root.CurrentJob;
task = root.CurrentTask;
runprop = root.CurrentRunprop;

% Allow ourselves one reportable error, which will be the first encountered. 
% This will be returned to the user and the task function will NOT be run.
% All other normal startup will happen
reportableException = [];

% Performs MATLAB Distributed Computing Server specific job initialization work,
% such as extracting the FileDependencies zip file and adding the
% appropriate directories to the MATLAB path.
try
    dctSchedulerMessage(4, 'About to pPreJobEvaluate');
    % Tell the job we are about to evaluate it
    job.pPreJobEvaluate(task);
catch e
    if isa(e, 'distcomp.ReportableException') 
        if isempty(reportableException)
            reportableException = e;
        end
    else
        throw(distcomp.ExitException(e, 'PreJobEvaluate'));
    end
end

try
    dctSchedulerMessage(4, 'About to pPreTaskEvaluate');
    % Tell the task we are about to evaluate it.
    task.pPreTaskEvaluate;
catch e
    if isa(e, 'distcomp.ReportableException') 
        if isempty(reportableException)
            reportableException = e;
        end
    else
        throw(distcomp.ExitException(e, 'PreTaskEvaluate'));
    end
end

% Set default outputs
DEFAULT_OUTPUT = {};
DEFAULT_TEXT = {''};
taskEvaluatedOK = false;
taskPostFcn = @iDoNothing;

if isempty(reportableException)
    try
        % Carry out the evaluation
        [resultsFcn, taskPostFcn, taskEvaluatedOK] = iEvaluateTask(job, task, runprop);
    catch e
        if isa(e, 'distcomp.ReportableException')
            % Define a suitable results function anonymously
            resultsFcn = @() iReturnResults(DEFAULT_OUTPUT, e.CauseException, DEFAULT_TEXT );
        elseif isa(e, 'distcomp.ExitException')
            rethrow(e);
        else
            throw(distcomp.ExitException(e, 'TaskEvaluate'));        
        end
    end
else
    % Define a suitable results function anonymously
    resultsFcn = @() iReturnResults(DEFAULT_OUTPUT, reportableException.CauseException, DEFAULT_TEXT );
end

try
    postFcns = [...
                {{taskPostFcn}} ...
                {{@iFinishTask, finishFcn, job, task, resultsFcn}} ...
                postFcns ];
    if job.pCurrentTaskIsPartOfAPool && taskEvaluatedOK
        % If the job is interactive then save the call to iFinishTask in the postFcns
        % and drop back to the base workspace, expecting someone to call
        % dctFinishInteractiveSession at some point in the future.
        dctStoreFunctionArray('set', postFcns);
    else
        dctEvaluateFunctionArray(postFcns);
    end
catch e
    throw(distcomp.ExitException(e, 'TaskFinish'));
end

end

% -------------------------------------------------------------------------
% Wrapper to call the finish function passed into this file on the correct
% data extracted from the results function
% -------------------------------------------------------------------------
function iFinishTask(finishFcn, job, task, resultsFcn)
finishFcn( job, task, resultsFcn() );
end

% -------------------------------------------------------------------------
% Do nothing - needed as task finished function if the task fails
% -------------------------------------------------------------------------
function iDoNothing
end

% -------------------------------------------------------------------------
% Internal function to evaluate the task
% -------------------------------------------------------------------------
function [resultsFcn, postTaskFcn, taskEvaluatedOK] = iEvaluateTask(job, task, runprop)

% Set default outputs that will be used by the nested functions - this is 
% the only data that should be shared by the nested fuctions. All the rest
% should remain within the individual functions scope
output = {};
cellTextOutput = {''};
errOutput = MException('', '');
% Did we succeed - this will be set to true in nEvaluateTask if we eval OK
taskEvaluatedOK = false;
% Do we need to capture text - this is set in nEvaluateTask and used in
% nPostFinishTask
capText = false;

% This function handle will return the correct structure of results for the
% finish function to use
resultsFcn = @nReturnResults;
% Function that will be called when the task really finishes. Until we have
% actually executed the task this is nothing, but later it is the nested
% task finish function
postTaskFcn = @iDoNothing;

% As we have setup the outputs from this function it is now safe to return
% at any time.
nEvaluateTask();
% Did we get to the end?
if taskEvaluatedOK
    % Only once the function is complete should we set the task finish
    % function appropriately.
    postTaskFcn = @nPostTaskFinish;
    % Resolve finish function in case of path change after this
    taskFinishFcn = @taskFinish;
end

return
% Below this there will only be nested functions that use the above
% variables to execute the parts of the task.

    function out = nReturnResults
        out = iReturnResults(output, errOutput, cellTextOutput);
    end

    function nEvaluateTask
        try
            dctSchedulerMessage(4, 'About to add job dependencies');
            % Add any PathDependencies or FileDependencies - this function can
            % throw errors and ReportableException to indicate failure.
            dependencyMap = iAddJobDependencies(job, runprop);
            
            % Have we been asked to capture text from this task?
            capText = task.CaptureCommandWindowOutput;
            
            if runprop.IsFirstTask
                dctSchedulerMessage(4, 'About to call jobStartup');
                % Perform user provided job startup steps for the new job.  Any
                % errors thrown here will appear in the Task's ErrorMessage and
                % ErrorIdentifier fields and text output will be captured
                [~, errOutput, cellTextOutput{end+1}] = dctEvaluateFunction(@jobStartup, 0, {job}, capText);
                if iThrewError(errOutput)
                    % Set error message and identifier
                    newMessage = sprintf('Error thrown in user-supplied jobStartup function\n(%s)', which('jobStartup'));
                    errOutput = iUpdateError(errOutput, newMessage, 'distcomp:jobstartup:usererror');
                    % No point in continuing if we threw an error
                    return;
                end
            end
            
            dctSchedulerMessage(4, 'About to call taskStartup');
            % Perform task startup steps for the new task.  Any errors thrown
            % here will appear in the Task's ErrorMessage and ErrorIdentifier
            % fields
            [~, errOutput, cellTextOutput{end+1}] = dctEvaluateFunction(@taskStartup, 0, {task}, capText);
            if iThrewError(errOutput)
                % Set error message and identifier
                newMessage = sprintf('Error thrown in user-supplied taskStartup function\n(%s)', which('taskStartup'));
                errOutput = iUpdateError(errOutput, newMessage, 'distcomp:taskstartup:usererror');
                % No point in continuing if we threw an error
                return;
            end
            
            try
                dctSchedulerMessage(4, 'About to get evaluation data');
                % Get all data necessary for task evaluation - this might throw errors
                % if the task has been deleted or is not available.
                [fcn, nOut, args] = task.pGetEvaluationData;
            catch errOutput
                newMessage = sprintf('Error encountered while getting input data from the task.');
                errOutput = iUpdateError(errOutput, newMessage, 'distcomp:task:dataInputError');
                return
            end
            
            try
                % If we are a matlabpool (interactive or batch) then startup now.
                % It is very important that this happen as close to the end of task
                % evaluation as possible as the timeout for pool connection is only
                % 30s. If this happens too early and there are problems with the
                % scheduler or file system then we will timeout. We were seeing
                % this issue during testing, and hence moved this here. One other
                % point to note is that ANY delay in taskStartup will be part of
                % the pool timeout and hence can STOP pools being built. It is by
                % design that jobStartup occur before pool instantiation and
                % taskStartup after - this allows user code to run in both of the
                % available contexts.
                if job.pIsMatlabPoolJob
                    dctSchedulerMessage(4, 'About to pInstantiatePool');
                    job.pInstantiatePool(task, fcn, nOut, args);
                    dctSchedulerMessage(4, 'Pool instatiation complete');
                    % Once the pool is built we need to tell it about the
                    % dependency map so that updates to those files can be
                    % correctly replicated.
                    obj = distcomp.getInteractiveObject;
                    obj.addFileDependenciesToPool( runprop.DependencyDirectory, dependencyMap );
                    
                    dctSchedulerMessage(4, 'About to call poolStartup');
                    % Perform startup steps after the pool is instantiated.  Any errors thrown
                    % here will appear in the Task's ErrorMessage and ErrorIdentifier
                    % fields
                    [~, errOutput, cellTextOutput{end+1}] = dctEvaluateFunction(@poolStartup, 0, {}, capText);
                    if iThrewError(errOutput)
                        % Set error message and identifier
                        newMessage = sprintf('Error thrown in user-supplied poolStartup function\n(%s)', which('poolStartup'));
                        errOutput = iUpdateError(errOutput, newMessage, 'distcomp:poolstartup:usererror');
                        % No point in continuing if we threw an error
                        return;
                    end
                end
            catch e
                if isa(e, 'distcomp.ReportableException')
                    throw(e)
                else
                    throw(distcomp.ExitException(e, 'PoolInstantiation'));
                end
            end
            
            % There is a race condition on all schedulers between bits of preceding code and task evaluation
            % where one particular lab might start evaluating the task function much earlier than others.
            % We therefore insert a labBarrier here to ensure that everyone leaves this point at the same time.
            % Currently we are only doing this for simpleparalleljob but we might well consider doing this
            % for all jobs. We have held off because this might negatively impact out jobmanager until we are
            % more knowlegdable about mpi library unloading and cleanup
            %
            % Don't do this for matlabpool jobs because they are already
            % undertaking synchronization in distcomp.nop and session startup. Thus
            % the race condition does not apply.
            if isa(job, 'distcomp.simpleparalleljob') && ~isa(job, 'distcomp.simplematlabpooljob')
                labBarrier;
            end
            
            % Evaluate the users function here - NOTE that we do not exit the
            % function if this fails - we still might need to release any resources
            % that were created in the taskStartup function.
            dctSchedulerMessage(1, 'Begin task function');
            [output, errOutput, cellTextOutput{end+1}] = dctEvaluateFunction(fcn, nOut, args, capText);
            dctSchedulerMessage(1, 'End task function');
            
        catch err
            % Catch special error types and simply rethrow - anything else is
            % considered to be a task error.
            if isa(err, 'distcomp.ReportableException') || isa(err, 'distcomp.ExitException')
                rethrow(err)
            end
            % General catch for an unexpected error in the evaluation
            errOutput = MException('distcomp:taskevaluation:UnexpectedError', 'UNEXPECTED ERROR in dctEvaluateTask/nEvaluateTask.');
            errOutput = errOutput.addCause(err);
            return
        end
        % The task has now evaluated successfully so indicate as such
        taskEvaluatedOK = true;
    end

    function nPostTaskFinish
        try
            % Initiate stopping of the labs. Do this part only on the client.
            if job.pIsMatlabPoolJob 
                dctSchedulerMessage(4, 'About to shutdown pool');
                poolShutdownOK = job.pShutdownPool;
                dctSchedulerMessage(4, 'Pool shutdown complete - labs shutdown OK == %d', poolShutdownOK);
            end
        catch e
            dctSchedulerMessage(4, 'Error in pool shutdown\n %s', e.getReport);
            if isa(e, 'distcomp.ReportableException')
                throw(e)
            else
                throw(distcomp.ExitException(e, 'PoolInstantiation'));
            end
        end
        try
            dctSchedulerMessage(4, 'About to call taskFinish');
            % Perform task finished steps. Note :
            %  1. this will always be evaluated even if the task threw an error.
            %  2. if this errors the task will be treated as erroring
            [~, finishErrOutput, cellTextOutput{end+1}] = dctEvaluateFunction(taskFinishFcn, 0, {task}, capText);
            
            % If any errors occurred (especially in taskFinish) ensure that there is
            % no output returned to the user
            if iThrewError(finishErrOutput)
                errOutput = finishErrOutput;
                output = {};
                % Set error message and identifier
                newMessage = sprintf('Error thrown in user-supplied taskFinish function\n(%s)', which('taskFinish'));
                errOutput = iUpdateError(errOutput, newMessage, 'distcomp:taskfinish:usererror');
            end
        catch err
            if isa(err, 'distcomp.ExitException')
                rethrow(err)
            elseif isa(err, 'distcomp.ReportableException') 
                err = err.CauseException;
            end
            % General catch for an unexpected error in the evaluation
            errOutput = MException('distcomp:taskevaluation:UnexpectedError', 'UNEXPECTED ERROR in dctEvaluateTask/nPostTaskFinish.');
            errOutput = errOutput.addCause(err);
        end
    end

end

% -------------------------------------------------------------------------
% This function packs up the output, errOutput and cellTextOutput
% appropriately for result submission.
% -------------------------------------------------------------------------
function out = iReturnResults(output, errOutput, cellTextOutput)
% Now massage the output to concatentate the textual output - remove
% the empty cells and join the rest
cellTextOutput(cellfun(@isempty, cellTextOutput)) = [];
textOutput = sprintf('%s', cellTextOutput{:});
% Package up the output into a structure to pass around easily
out = struct('output', {output}, 'errOutput', {errOutput}, 'textOutput', {textOutput});
end

% -------------------------------------------------------------------------
% Internal function to correctly add the PathDependencies and
% FileDependencies
% -------------------------------------------------------------------------
function dependencyMap = iAddJobDependencies(job, runprop)

try
    % Add PathDependencies to the MATLAB path - these need to be higher on the
    % path than toolboxes but lower than FileDependencies
    if runprop.AppendPathDependencies
        pathDependencies = job.PathDependencies;
        if ~isempty(pathDependencies)
            % Add to the top of the path
            addpath(pathDependencies{:});
        end
    end
catch err
    errOutput = MException('distcomp:taskevaluation:PathDependenciesError', ...
        'Error encountered while adding PathDependencies to MATLAB path.');
    errOutput = errOutput.addCause(err);
    % Throw a reportable error for the caller to pick up
    throw(distcomp.ReportableException(errOutput));
end

try
    % Add FileDependencies to the MATLAB path
    if runprop.AppendFileDependencies
        dependencydir = runprop.DependencyDirectory;
        dependencyMap = dctAddFileDependenciesToPath(job, dependencydir);
    else
        dependencyMap = cell(0, 2);
    end
catch err
    errOutput = MException('distcomp:taskevaluation:FileDependenciesError', ...
        'Error encountered while adding FileDependencies to MATLAB path.');
    errOutput = errOutput.addCause(err);
    % Throw a reportable error for the caller to pick up
    throw(distcomp.ReportableException(errOutput));
end

if runprop.AppendFileDependencies || runprop.AppendPathDependencies
    % Force MATLAB to pick up the new files - note this takes some time (~0.5s)
    clear('functions');
    try
        % If Simulink is loaded then ask it to clear it's systems - NOTE we should 
        % NOT load Simulink if it is not already loaded
        if iIsSimulinkLoaded 
            bdclose('all');
        end
    catch e %#ok<NASGU>
        % Don't worry if this errors, it was just a best effort to not have any
        % simulink models in memory. 
    end
end

end
% -------------------------------------------------------------------------
% Internal function to check if an error stack (as returned from lasterror)
% actually contains an error.
% -------------------------------------------------------------------------
function OK = iThrewError(errOutput)
% This function ASSUMES that errOutput is a value that has been returned
% from the lasterror or MException command;
OK = ~isempty(errOutput.message);
end

% -------------------------------------------------------------------------
% Internal function to check if an error stack (as returned from lasterror)
% actually contains an error.
% -------------------------------------------------------------------------
function newErr = iUpdateError(originalErr, newMessage, newIdentifier)
if ~isa(originalErr, 'MException')
    dctSchedulerMessage(0, 'Unexpected lasterror struct returned to dctEvaluateTask');
    originalErr = MException(originalErr.identifier, '%s', originalErr.message);
end
newErr = MException(newIdentifier, '%s', newMessage);
newErr = newErr.addCause(originalErr);
end

% -------------------------------------------------------------------------
% Internal function to check if the simulink library is loaded - this is
% done via version rather than a license check because there are some edge
% case situations what a license check misses
% -------------------------------------------------------------------------
function OK = iIsSimulinkLoaded()
moduleOutput = evalc('version -modules');
regexpMatlabroot = strrep(matlabroot, '\', '\\');
OK = ~isempty(regexp(moduleOutput , [regexpMatlabroot '[^\n]*libmwsimulink'], 'once'));
end
