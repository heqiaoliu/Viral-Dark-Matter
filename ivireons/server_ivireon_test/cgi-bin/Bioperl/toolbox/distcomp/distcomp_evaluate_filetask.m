function distcomp_evaluate_filetask(varargin)
; %#ok Undocumented
% Accepts a job and task and computes and returns
% the results of the task and then exits matlab
%

% Copyright 2005-2010 The MathWorks, Inc.

mlock;
handlers = struct(  'abortFcn',     @nAbortFunction, ...
                    'exitFcn',      @nExitFunction, ...
                    'errorFcn',     @nAbortFunction);

% Default all messages to disp to start with.
setSchedulerMessageHandler(@disp)

% Performs MATLAB Distributed Computing Server specific job initialization work
try
    runprop = iSetup(handlers, varargin);
catch err
    handlers.abortFcn(err, 'Job setup failed - MATLAB will now exit.');
end
% Ensure that this function always exits if necessary
try
    postFcns = {};
    if runprop.ExitOnTaskFinish
        postFcns = [ ...
            {{handlers.exitFcn}} ...
            postFcns];
    end
    % Test if we should remove the DependencyDirectory at the end
    if runprop.CleanUpDependencyDirOnTaskFinish && ...
        ~exist(runprop.DependencyDirectory, 'dir')
            postFcns = [ ...
                {{@iRemoveDependencyDir runprop.DependencyDirectory}} ...
                postFcns];
    end
    % Actually do the task evaluation stuff
    iDoTask(handlers, postFcns);
    % NOTE - do not add any code after the call to iDoTask as this will NOT get
    % executed if runprop.ExitOnTaskFinish is true. Generally this is true!
catch err
    handlers.abortFcn(err, 'Unexpected error in DoTask - MATLAB will now exit and restart.');
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
        iExitOnException(1);
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
        iExitOnException(0);
    end

end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function iDoTask(handlers, postFcns)
% Need to know what the original path of matlab is - because the user might
% change this during the course of running their code and stop us removing
% some directories later.
persistent originalPath;
if isempty(originalPath)
    originalPath = path;
end

try
    finishFcn = @(job, task, out) iFinishTask(handlers, job, task, out, originalPath);
    dctEvaluateTask(postFcns, finishFcn);
catch e
    if isa(e, 'distcomp.ExitException')
        handlers.errorFcn(e.CauseException, 'Unexpected error in %s - MATLAB will now exit.', e.message);
    else
        handlers.errorFcn(e, 'Unexpected error whilst running task - MATLAB will now exit.');
    end
end

end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function iFinishTask(handlers, job, task, out, originalPath)
% If we are going to clean up the dependency directory later then we need to
% reset the matlab path because this might stop us deleting some dirs.
try
    runprop = get(distcomp.getdistcompobjectroot, 'CurrentRunprop');
    if runprop.CleanUpDependencyDirOnTaskFinish
        path(originalPath);
    end
catch e
    dctSchedulerMessage(1, 'Unable to revert to original path - continuing\nNested Error:%s', e.getReport);
end

try
    task.pPostTaskEvaluate(out.output, out.errOutput, out.textOutput);
catch e
    handlers.errorFcn(e, 'Unable to submit task result - MATLAB will now exit.');
end

try
    job.pPostJobEvaluate;
catch e %#ok<NASGU> - Do nothing if this throws an error
end

end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function iRemoveDependencyDir(dirName)
% May need to remove the dependency directory
try
    if exist(dirName, 'dir')
        rmdir(dirName, 's');
    end
catch e %#ok<NASGU> - Tell the user - but OK to continue
    dctSchedulerMessage(1, 'Unable to remove dependency directory %s', dirName)
end
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function iExitOnException(exitStatus)
% If no exit status is defined then assume 1
if nargin < 1
    exitStatus = 1;
end
[isWorker, isDebugWorker] = system_dependent('isdmlworker');
if isWorker && ~isDebugWorker
    % If we are exiting normally then try and give everyone a chance to clean up
    % before we exit.
    if exitStatus == 0
        try
            exit('force');
            % Give matlab a while to close down
            pause(5) %#ok<UNRCH> Just in case MATLAB fails to exit
        catch e  %#ok<NASGU>
        end
    end
    % Kill MATLAB hard, without giving anyone a chance  to run their static
    % finalizers.
    pm = com.mathworks.toolbox.distcomp.nativedmatlab.ProcessManipulation();
    pm.sendSIGKILL;
end

end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function runprop = iSetup(handlers, decodeArguments)
% NOTE - this function can be called multiple times in an SOA type
% infrastructure and it is essential that it deal with these multiple calls
import com.mathworks.toolbox.distcomp.distcompobjects.SchedulerProxy

iExecuteHook('MDCE_QE_PRE_JOB_SETUP');

persistent decodeFunction
try
    % Make sure this matlab cannot core dump and exits on segv - this might
    % be changed by internal code so ensure it is done every job or task
    out = system_dependent(100, 2); %#ok<NASGU> - capture return so that we don't get alarming message printed
    dct_psfcns('ensureProcessExitsOnFault');
    % Initialize the MatlabRefStore
    com.mathworks.toolbox.distcomp.util.MatlabRefStore.initMatlabRef();
catch err
    dctSchedulerMessage(0, 'Unexpected error occurred during setup.');
    dctSchedulerMessage(0, 'Error returned was:\n%s', err.getReport);
    iExitOnException(1);
end

% Only deduce the decodeFunction once per MATLAB session. NOTE that
% this whole file is mlocked and so this persistent variable cannot be
% cleared.
if isempty(decodeFunction)
    decodeFunctionString = '';
    try
        decodeFunctionString = getenv('MDCE_DECODE_FUNCTION');
        % How should we interpret the environment?
        decodeFunction = str2func(decodeFunctionString);
        % We'll check decodeFunction is a valid function handle later on
        % when we call it.
    catch err
        dctSchedulerMessage(0, ['Error converting the environment variable MDCE_DECODE_FUNCTION to a function handle.\n' ...
            'This is probably because the environment variable (MDCE_DECODE_FUNCTION) does not exist.\n' ...
            'The MDCE_DECODE_FUNCTION variable''s current value is "%s"'], decodeFunctionString);
        dctSchedulerMessage(0, 'Error returned was:\n%s', err.getReport);
        iExitOnException(1);
    end
end

% Since we are running on a third-party scheduler there is a good chance that
% we have been launched by worker or worker.bat. Under these circumstances it
% is often hard for the scheduler to kill the matlab. Thus we may well want to
% fire up a process watching thread that will kill this matlab if the relevant
% process being watched dies.
persistent processMonitoringThreadStarted;
try
    if isempty(processMonitoringThreadStarted) || ~processMonitoringThreadStarted
        iSetupProcessMonitoringThreads;
        processMonitoringThreadStarted = true;
    end    
catch err
    dctSchedulerMessage(0, 'Unexpected error setting up process monitor. Error returned:\n%s', err.getReport);
    iExitOnException(1);
end

try
    % Explicitly set the number of computational threads to 1 on a worker. The user
    % may choose to override this using jobStartup.
    s = warning('off', 'MATLAB:maxNumCompThreads:Deprecated');
    maxNumCompThreads( 1 );
    warning(s);
catch err
    dctSchedulerMessage( 1, 'Warning - failed to set number of computational threads. Error thrown was:\n%s\n', ...
                         err.getReport );
end

% Deal with MDCE_PARALLEL, if set - this is the one place where the MPI
% code is told to initialise and hang off MPI_COMM_WORLD. Note that
% local scheduler job will connect/accept off this later in the decode
% function. Thus it is essential that this occur before we call the decode
% function
if ~isempty( getenv( 'MDCE_PARALLEL' ) )
    try
        mpiInit;
        mpiParallelSessionStarting;
    catch err
        dctSchedulerMessage(0,  'Error initialising MPI: %s', err.getReport );
        iExitOnException(1);
    end
end

% Create a runprop object to hold the information necessary to create the
% taskrunner and proxy objects
runprop = distcomp.runprop;
% File tasks should default to exiting when finished
runprop.ExitOnTaskFinish = true;
% Since we are going to exit when the task is finished, we will need to also clean
% up our dependency dir, otherwise it's going to get left behind
runprop.CleanUpDependencyDirOnTaskFinish = true;
runprop.DecodeArguments = decodeArguments;

if isempty( getenv( 'MDCE_DEBUG' ) ) || strcmpi(getenv('MDCE_DEBUG'), 'false')
    % Log only level 0 messages if MDCE_DEBUG isn't defined or is 'false' - this can be
    % overridden in the decode function below or by defining this
    % variable. Note that environment variables must be definable at this
    % point as we have correctly identified a decode function using one.
    setSchedulerMessageHandler(@iDispLevelZeroMessages)
end

try
    % The decode function will fill in the correct parts of the runprop object
    % and we can then use this to make storage and task runner objects
    decodeFunction(runprop);
catch err
    if strcmp(err.identifier, 'MATLAB:UndefinedFunction') && isempty(err.stack)
        % Turns out that the function handle wasn't valid, so log this information.
        % NB if the decodeFunction itself contains code that caused an UndefinedFunction
        % error, the error stack will not be empty, and the "Error caught in decode function"
        % will appear in the log.
        dctSchedulerMessage(0, ['Decode function "%s" does not represent a valid MATLAB ', ...
            'function on the current matlab path'], decodeFunctionString);
    else
        dctSchedulerMessage(0, 'Error caught in decode function ("%s")', decodeFunctionString);
        dctSchedulerMessage(0, 'Error returned was:\n%s', err.getReport);
    end
    iExitOnException(1);
end

% Get the root object we are going to set against
root = distcomp.getdistcompobjectroot;
% Only construct scheduler and storage if this is the first task -
% otherwise re-use the existing one
if runprop.IsFirstTask
    dctSchedulerMessage(2, 'About to construct the storage object using constructor "%s" and location "%s"', runprop.StorageConstructor, runprop.storageLocation);
    try
        storageConstructor = str2func(runprop.StorageConstructor);
        % We'll test that we got a valid function handle later when 
        % we call it.
    catch err
        dctSchedulerMessage(0, ['Error converting the StorageConstructor to a function handle.\n' ...
            'This is probably because the value supplied in the decode function ("%s") was empty.\n' ...
            'The StorageConstructor''s current value is "%s"'], decodeFunctionString, runprop.StorageConstructor);
        dctSchedulerMessage(0, 'Error returned was:\n%s', err.getReport);
        iExitOnException(1);
    end
    try
        storage = storageConstructor(runprop.StorageLocation);
    catch err
        if strcmp(err.identifier, 'MATLAB:UndefinedFunction') && isempty(err.stack)
            % Turns out that the function handle wasn't valid, so log this information.
            % NB if the storageConstructor itself contains code that caused an UndefinedFunction
            % error, the error stack will not be empty, and the "Error finding the StorageLocation"
            % will appear in the log.
            dctSchedulerMessage(0, ['Returned value for StorageConstructor ("%s") does not represent a valid\n' ...
                'MATLAB function on the current matlab path\n' ...
                'This value was supplied by the decode function "%s"'], runprop.StorageConstructor, decodeFunctionString);
        else
            dctSchedulerMessage(0, ['Error finding the StorageLocation. This is probably \n'...
                'because the StorageLocation ("%s") \n' ...
                'from the decode function does not exist.\n'...
                'The error thrown by the StorageConstructor was : \n%s'], runprop.StorageLocation, err.getReport);
        end
        iExitOnException(1);
    end
    schedulerType = runprop.LocalSchedulerName;
    try
        sched = iCreateSchedulerObject(root, schedulerType, storage);
    catch err
        dctSchedulerMessage(0, 'Error constructing local scheduler object of type %s. The error thrown was : \n%s',...
            schedulerType, err.getReport);
        % Distinguish constructing the default runner with any other - if we fail on lsf, ccs or other possibilities
        % then fall back on the runner as a feasible solution.
        if ~strcmp(schedulerType, 'runner')
            dctSchedulerMessage(2, 'Trying to construct a default scheduler object.')
            try
                sched = iCreateSchedulerObject(root, 'runner', storage);
            catch err
                dctSchedulerMessage(0, 'Error constructing local scheduler object. The error thrown was :\n%s', err.getReport);
                iExitOnException(1);
            end
        else
            iExitOnException(1);
        end
    end
    sched.HasSharedFilesystem = runprop.HasSharedFilesystem;
else
    % Get scheduler to use from the root and extract storage from that.
    sched = root.CurrentJobmanager;
    storage = sched.pReturnStorage;
end

dctSchedulerMessage(2, 'About to find job proxy using location "%s"', runprop.JobLocation);
[jobProxy, jobConstructor] = storage.getProxyByName(runprop.JobLocation);
dctSchedulerMessage(2, 'About to find task proxy using location "%s"', runprop.TaskLocation);
taskProxy = storage.getProxyByName(runprop.TaskLocation);

try
    % Create the job and task
    job  = distcomp.createObjectsFromProxies(jobProxy, jobConstructor, sched);
    task = distcomp.createObjectsFromProxies(taskProxy, job.pReturnDefaultTaskConstructor, job);
    % Set the fields on the root object
    root.setCurrentTaskInfo(sched, [], job, task, runprop, handlers);
catch err
    dctSchedulerMessage(0, 'Error setting current job and task info');
    dctSchedulerMessage(0, 'Error returned was:\n%s', err.getReport);
    iExitOnException(1);
end

iExecuteHook('MDCE_QE_POST_JOB_SETUP');

dctSchedulerMessage(2, 'Completed pre-execution phase');
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function sched = iCreateSchedulerObject(root, type, storage)
import com.mathworks.toolbox.distcomp.distcompobjects.SchedulerProxy
schedulerConstructor = distcomp.getSchedulerUDDConstructor(type);
schedulerProxy = SchedulerProxy.createInstance(type, storage);
sched = distcomp.createObjectsFromProxies(schedulerProxy, schedulerConstructor, root);
end

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
    dctSchedulerMessage(2, 'Hook %s is defined : About to eval string\n%s', hookName, hookStr);
    try
        eval(hookStr);
    catch err
        dctSchedulerMessage(1, 'Hook %s threw an error. The error was\n%s', hookName, err.getReport);
    end
catch err %#ok<NASGU>
    % Do nothing if there is an error - this is a QE function only
end
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function iSetupProcessMonitoringThreads
% On windows we are likely to be parented by worker.bat, on unix we will have
% exec'd into the shell process. Thus under mpiexec we expect the following
% process trees
%
% win ...  smpd - worker.bat - matlab
% unix ... smpd - MATLAB - matlab_helper

% Have we been asked to watch a particular pid rather than our parent?
pidToWatch = getenv('MDCE_PID_TO_WATCH');
if ~isempty(pidToWatch)
    % Try converting to a double ...
    pidToWatch = str2double(pidToWatch);
    % Special PID to watch that says don't watch
    if pidToWatch == 0
        return
    end
    % Did we get anything sensible?
    if isfinite(pidToWatch) && uint32(pidToWatch) == pidToWatch && pidToWatch > 0
        % If we are successfully watching this one do we need to watch our parent?
        dct_psfcns('pidwatch', pidToWatch)
        return
    end
end

if ispc
    % Start the monitor to ensure that when our parent process terminates (which
    % will be the command-shell or shell/batch script running MATLAB), we
    % terminate the MATLAB process.
    dct_psfcns( 'winparentprocesscheck' );
end

end


%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function iDispLevelZeroMessages(message, messageLevel)
% Function to display only those dctSchedulerMessages whose log levels 
% are equal to zero.
desiredLevel = 0;
if messageLevel > desiredLevel
    return;
end

disp(message);
end
