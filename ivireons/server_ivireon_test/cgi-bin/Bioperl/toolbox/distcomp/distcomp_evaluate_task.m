function distcomp_evaluate_task( jobManagerProxy, workerProxy, ...
                                 jobAndTask, jobType, performJobInit, justStarted, ...
                                 taskLogLevel, encrytedAuthToken )
; %#ok Undocumented
% Accepts a worker, job, and task and computes and submits
% the results of the task.
%
% performJobInit indicates whether this is the first task that has been run
% from this job by this worker.
%
% justStarted indicates whether this is
% the first task that has been run by this worker since it was last
% started

% Copyright 2004-2010 The MathWorks, Inc.

mlock; % so that the originalpath persistent variable is saved (see iSetup)

handlers = struct(  'abortFcn',     @nAbortFunction, ...
                    'exitFcn',      @nExitFunction, ...
                    'errorFcn',     @nErrorFunction);

% Remember to set the scheduler message handler.
setSchedulerMessageHandler( javaWorkerMessageHandler() );

% And to configure the TaskHandler. Cleaned up in iFinishTask()
iSetupTaskHandler(jobManagerProxy, jobAndTask, taskLogLevel);

dctSchedulerMessage(1, 'Begin distcomp_evaluate_task');

% Performs MATLAB Distributed Computing Server specific job initialization work
try
runprop = iSetup(jobManagerProxy, workerProxy, jobAndTask, jobType, ...
                 performJobInit, justStarted, encrytedAuthToken, handlers); %#ok<NASGU>
catch err
    handlers.errorFcn(err, 'Job setup failed - MATLAB will now exit and restart.');
end

try
    % Define any post processing tasks that we want to evaluate and send them in
    % to the run function - this allows us to ensure that these will get run when
    % the finish function is called.
    % This function could be called AFTER a task has been dispatched to the
    % worker (which would happen when pSubmitResult is called).
    postFcns = {{@makeJavaWorkerIdle, workerProxy, jobAndTask}};
    % Actually do the task evaluation stuff
    iDoTask(handlers, postFcns);
    % NOTE - do not add any code after the call to iDoTask as this will NOT get
    % executed in the case of an interactive parallel job. Any code that needs to
    % run after the users code has executed should be added into iFinishTask below.
catch err
    handlers.abortFcn(err, 'Unexpected error in DoTask - MATLAB will now exit and restart.');
end

dctSchedulerMessage(1, 'End distcomp_evaluate_task');


%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
    function nErrorFunction(err, varargin)
        % Helper function that will exit matlab if the last error that we detected
        % was related to not finding a job or task. The reasoning behind this is that
        % if a job or task is not found then we are about to be shutdown by the
        % jobmanager, so we might as well do it ourselves.
        try
            if ~isempty(regexp(err.identifier, 'distcomp:(job|task):NotFound', 'match', 'once'))
                dctSchedulerMessage(2, 'MATLAB will now exit and restart as a job or task was destroyed while this worker was executing it');
                handlers.exitFcn();
            else
                handlers.abortFcn(err, varargin{:});
            end
        catch e %#ok<NASGU> - don't want this function to EVER error
            handlers.abortFcn(err, varargin{:});
        end
    end
%--------------------------------------------------------------------------
% Define a nested abort function that retains the relevant information we
% want, such as jWorker, jJobID and jTaskID
%--------------------------------------------------------------------------
    function nAbortFunction(err, varargin)
        try
            if nargin > 1
                % Display some textual output if requested
                dctSchedulerMessage(0, varargin{:})
            end
        catch e %#ok<NASGU> - don't want this function to EVER error
        end
        try
            dctSchedulerMessage(0, err.getReport);
        catch e %#ok<NASGU> - don't want this function to EVER error
        end
        % Always exit - no matter what
        iExitOnException(workerProxy, jobAndTask);
    end
%--------------------------------------------------------------------------
% Define a nested exit function that retains the relevant information we
% want, such as jWorker, jJobID and jTaskID
%--------------------------------------------------------------------------
    function nExitFunction(varargin)
        try
            if nargin > 0
                % Display some textual output if requested
                dctSchedulerMessage(0, varargin{:})
            end
        catch e %#ok<NASGU> - don't want this function to EVER error
        end
        % Always exit - no matter what
        iExitOnException(workerProxy, jobAndTask);
    end

end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function iDoTask(handlers, postFcns)

try
    finishFcn = @(job, task, out) iFinishTask(handlers, job, task, out);
    dctEvaluateTask(postFcns, finishFcn);
catch e
    if isa(e, 'distcomp.ExitException')
        handlers.errorFcn(e.CauseException, 'Unexpected error in %s - MATLAB will now exit and restart.', e.message);
    else
        handlers.errorFcn(e, 'Unexpected error whilst running task - MATLAB will now exit and restart.');
    end
end

end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function iFinishTask(handlers, job, task, out)

try
    % If the task is part of a paralleljob and it errored, we try and submit
    % the result and then exit.
    if isa( job, 'distcomp.paralleljob' )
        if ~isempty(out.errOutput.message)
            try
                task.pSubmitResult(out.output, out.errOutput, out.textOutput);
            catch e %#ok<NASGU>
                % Don't worry about being unable to cancel the current task,
                % this might fail if the current task no longer exists
                % We still want to exit normally without leaving log messages
                % because this is a normal code path
            end
            % Normal termination. Worker must not submit a result.
            handlers.exitFcn();
        end
    end
catch e
    handlers.errorFcn(e, 'Unexpected error in parallel job cleanup - MATLAB will now exit and restart.');
end

try
    job.pPostJobEvaluate();
catch e
    handlers.errorFcn(e, 'Unexpected error in PostJobEvaluate - MATLAB will now exit and restart.');
end

try
    task.pSubmitResult(out.output, out.errOutput, out.textOutput);
catch e
    handlers.errorFcn(e, 'Unable to submit task result - MATLAB will now exit and restart.');
end

pctSetmcrappkeys( '', '' );

try
    % Need to free up the cached tasks so we don't leak memory
    root = distcomp.getdistcompobjectroot;
    root.removeObjectFromHashtable(task.pReturnUUID);
    delete(task);
catch e %#ok<NASGU> Failure to delete from cache is not catastrophic
    dctSchedulerMessage(1, 'Warning - unable to remove task object from cache');
end

iClearTaskHandler();

end % iFinishTask

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function iExitOnException(worker, jobAndTask)
% This function errored out and the integrity of the running MATLAB can no longer be assumed.
% Terminate MATLAB to force it to be restarted. Print an error message and inform the Java worker
% that MATLAB is being terminated. Give the Java workers about a minute to terminate MATLAB.
% If that does not work, the exit command should be called.
try
    % An asynchronous call to inform the Java worker that MATLAB is going to exit.
    worker.restartWorkerOnError(jobAndTask);
catch e %#ok<NASGU> - don't want this function to EVER error
end
% Give the Java workers about 60 seconds to terminate MATLAB. Add a random value between 0 and 10
% to this timeout so as to minimize the possibility of workers interfering with one another as
% they update the toolboxcache during exit.
%
% Use Thread.sleep to ensure that any pending IQM requests cannot pre-empt
% this! pause allows other code to run.
java.lang.Thread.sleep((60 + floor(10*rand)) * 1000);
% Attempt to terminate gracefully by calling the exit command.
exit('force');
end % iExitOnException

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function runprop = iSetup(jobManagerProxy, workerProxy, jobAndTask, jobType, ...
                          performJobInit, justStarted, encrytedAuthToken, handlers)
persistent originalpath;
persistent originalWarningState;

% Check the worker and MATLAB agree on the computer type.
workerComputerType = char(workerProxy.getComputerMLType());
if ~strcmp( workerComputerType, computer )
    dctSchedulerMessage( 1, 'Worker and MATLAB don''t agree on computer type.' );
    error( 'distcomp:distcomp_evaluate_task:ComputerTypeMismatch',...
           'Worker computer type is "%s", but MATLAB computer type is "%s"', workerComputerType, computer );
end

iExecuteHook('MDCE_QE_PRE_JOB_SETUP');

rootDependencyDir = char(workerProxy.getFileDependencyDir);
workerDir = char(workerProxy.getWorkerDir);

if justStarted || performJobInit
    if isempty(originalpath)
        % initialize the original path
        originalpath = path;
        originalWarningState = warning('query', 'all');
    else
        % restore the original path before executing the next job
        path(originalpath);
        warning(originalWarningState);
    end

    if performJobInit                
        % Always try and delete the file dependencies directory if this is
        % the first task we are running.
        if exist(rootDependencyDir, 'dir')
            try 
                rmdir(rootDependencyDir, 's');
            catch err  %#ok<NASGU>
                % Don't worry too much if we can't do this as it is actually
                % quite likely to happen on windows if the matlab hasn't
                % restarted. At some point we are going to be able to delete
                % the contents of this dir.
            end
        end
        
        % Make sure the worker directory exists.
        if ~exist(workerDir, 'dir')
            mkdir(workerDir);
        end
    end
    
    % Do this now so that users only need to override this in jobStartup
    try
        % Explicitly set the number of computational threads to 1 on a worker. 
        s = warning('off', 'MATLAB:maxNumCompThreads:Deprecated');
        maxNumCompThreads( 1 );
        warning(s);
    catch err
        dctSchedulerMessage( 1, 'Warning - failed to set number of computational threads. Error thrown was:\n%s\n', ...
                             err.message );
    end
end

% Ensure that any changes made by mpiprofile to general profiler settings
% have been reverted.
try
    mpiprofile( 'reset' );
catch err
    dctSchedulerMessage( 1, 'Warning - failed to reset profiler state. Error thrown was:\n%s\n', ...
                         err.message );
end

% We wish to ensure that the current working directory of matlab is not a
% UNC path on windows, and possibly that it is writable by this process.
% So lets ensure that we change directory to the local work directory
cd(workerDir);

% Create the correct runprop data
runprop = distcomp.runprop;
% Add PathDependencies if the worker has just restarted or if this is the
% first task in a job this worker has processed
runprop.AppendPathDependencies = justStarted || performJobInit;
% Add FileDependencies if this is the first task in a job
runprop.AppendFileDependencies = justStarted || performJobInit;
% Is this the first task in this job that the worker has executed
runprop.IsFirstTask = performJobInit;

try
    root = distcomp.getdistcompobjectroot;
    % Make sure that all the proxies are correctly rooted in my hierarchy
    jobmanager = distcomp.createObjectsFromProxies(jobManagerProxy, @distcomp.jobmanager, root);
    % Might need to clean up previous jobs
    if runprop.IsFirstTask
        try
            % Find all objects down from the jobmanager
            previousObjs = find(jobmanager);
            % Remove the jobmanager from the first in the list
            previousObjs(1) = [];
            if ~isempty(previousObjs)
                uuids = previousObjs.pReturnUUID;
                delete(previousObjs);
                root.removeObjectFromHashtable(uuids);
            end
        catch err %#ok<NASGU>
            % This is not a serious enough error that we don't run the job
            dctSchedulerMessage(1, 'Warning - unable to remove job objects from cache');
        end
    end
    worker = distcomp.createObjectsFromProxies(workerProxy, @distcomp.worker, root);
    constructor = jobmanager.pGetUDDConstructorsForJobTypes( jobType );
    job = distcomp.createObjectsFromProxies( jobAndTask.getJobID(), constructor, jobmanager);
    task = distcomp.createObjectsFromProxies( jobAndTask.getTaskID(), @distcomp.task, job);

    % Create a CredentialStore
    authToken = encrytedAuthToken.unpack();
    credentialStore = ...
        com.mathworks.toolbox.distcomp.auth.credentials.store.CredentialStore(authToken);
    % Set the credentials store in the jobmanager proxy (and all access proxies).
    jobmanager.pSetCredentialStore(credentialStore);
    % Set the consumer factory.
    consumerFactory = com.mathworks.toolbox.distcomp.auth.credentials.consumer.CredentialConsumerFactory.TRIVIAL_FACTORY;
    jobmanager.pSetCredentialConsumerFactory(consumerFactory);
    % Set the username in the jobmanager proxy (which sets it in all access proxies).
    jobmanager.pSetUserName(authToken.getUserIdentity());

catch err
    rethrow(err);
end

% Tell it where the DependencyDirectory is located
runprop.DependencyDirectory = fullfile(rootDependencyDir, num2str(job.ID));

try
    % Set the properties on the root object
    setCurrentTaskInfo(root, jobmanager, worker, job, task, runprop, handlers);
catch err
    rethrow(err);
end

iExecuteHook('MDCE_QE_POST_JOB_SETUP');

end %iJobStartup

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function iExecuteHook(hookName)
try
    hookStr = getenv(hookName);
    % Nothing defined for this hook - return immediately
    if isempty(hookStr)
        return
    end
    dctSchedulerMessage(0, 'Hook %s is defined : About to eval string\n%s', hookName, hookStr);
    try
        eval(hookStr);
    catch err
        dctSchedulerMessage(0, 'Hook %s threw an error. The error was\n%s', hookName, err.message);
    end
catch err  %#ok<NASGU>
    % Do nothing if there is an error - this is a QE function only
end
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function iSetupTaskHandler(jobManagerProxy, jobAndTask, taskLogLevel)
taskHandler = iGetTaskHandler();
taskHandler.setTaskAccess(jobManagerProxy.getTaskAccess());
taskHandler.setTaskIDAndLevel(jobAndTask.getTaskID(), taskLogLevel);
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function iClearTaskHandler()
taskHandler = iGetTaskHandler();
taskHandler.flush();
taskHandler.clearTaskIDAndLevel();
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function taskHandler = iGetTaskHandler()
persistent theTaskHandler;
if isempty(theTaskHandler)
    % First try and find one attached to the logger
    logger = com.mathworks.toolbox.distcomp.worker.PackageInfo.LOGGER;
    handlers = logger.getHandlers();
    for n = 1:length(handlers)
        if isa(handlers(n), 'com.mathworks.toolbox.distcomp.logging.TaskHandler')
            dctSchedulerMessage(6, 'Found existing TaskHandler')
            theTaskHandler = handlers(n);
            break;
        end    
    end
    % If failed to find one, create a new one and add it to the logger.
    if isempty(theTaskHandler)        
        dctSchedulerMessage(6, 'Creating new TaskHandler')
        theTaskHandler = com.mathworks.toolbox.distcomp.logging.TaskHandler([]);
        logger.addHandler(theTaskHandler);
    end
end
taskHandler = theTaskHandler;
end
