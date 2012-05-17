function  errmsg = validateConfig(validationClient, config, timeout)
; %#ok Undocumented
%VALIDATECONFIG Validate a given Parallel Computing Toolbox configuration
%
% validateConfig(validationClient, 'config', timeout) validates the 'config'
% configuration. timeout represents the maximum time to allow a job or 
% matlabpool open to run before aborting the given validation stage and
% moving on to the next. validationClient is a non-null instance of 
% com.mathworks.toolbox.distcomp.configui.validation.ValidatorClient 
% interface used as a callback handle. 
%
% validateConfig(validationClient, 'config') validates the 'config'
% configuration. Jobs and matlabpool will not timeout. validationClient 
% is a non-null instance of 
% com.mathworks.toolbox.distcomp.configui.validation.ValidatorClient 
% interface used as a callback handle. 
%
%
% validateConfig(validationClient) validates the default
% configuration. Jobs and matlabpool will not timeout. validationClient 
% is a non-null instance of 
% com.mathworks.toolbox.distcomp.configui.validation.ValidatorClient 
% interface used as a callback handle. 
%
% err = validateConfig(...) returns the error message of any unexpected
% exception that may have been thrown during validation.

% Copyright 2008-2010 The MathWorks, Inc.

% Determine timeout:
if nargin < 3
    timeout = Inf; % default: no timeout
end;

% Determine the configuration to validate:
if nargin < 2
    config = defaultParallelConfig();
end

errmsg = '';
[lastMsg, lastID] = lastwarn;
lastwarn('');
try
    doValidate(validationClient, config, timeout);
catch lastErr
    errmsg = lastErr.getReport();
end
lastwarn(lastMsg, lastID);

end
%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function doValidate(validationClient, config, timeout)
% Make sure the SessionFactory.sAllowedToStart is reset when done:
allowMatlabPoolOpenCleanup = onCleanup(@iResetMatlabpoolOpenAllowed);

import com.mathworks.toolbox.distcomp.configui.validation.*;

% Define if this is a terminal situation to the GUI or not
TERMINATE_TESTING = true;

%% Step 1: get the scheduler
% Note any failure to get the scheduler terminates the validation.

validationClient.stageRunning(ValidationStage.FIND_RESOURCE);
    
cmdWinOutput = '';
try
    findResourceFcn = @() findResource('scheduler', 'configuration', config); %#ok<NASGU> - used in evalc
    [cmdWinOutput, scheduler] = evalc('findResourceFcn()');
catch lastErr
    validationClient.stageFailed(ValidationStage.FIND_RESOURCE, TERMINATE_TESTING, cmdWinOutput, FailureMode.UNCLASSIFIED_ERROR, iGetErrorReport(lastErr), []);
    return;
end
    
% Couldn't find scheduler?
if numel(scheduler) == 0
    validationClient.stageFailed(ValidationStage.FIND_RESOURCE, TERMINATE_TESTING, cmdWinOutput, FailureMode.SCHEDULER_NOT_FOUND, [],[]);
    return;
% More than 1 scheduler found:
elseif numel(scheduler) > 1
    validationClient.stageFailed(ValidationStage.FIND_RESOURCE, TERMINATE_TESTING, cmdWinOutput, FailureMode.MULTIPLE_SCHEDULERS_FOUND, [],[]);
    return;
end

% Cluster is empty?
if scheduler.ClusterSize == 0
    validationClient.stageFailed(ValidationStage.FIND_RESOURCE, TERMINATE_TESTING, cmdWinOutput, FailureMode.CLUSTER_EMPTY, [],[]);
    return;
end

if ~isempty(lastwarn)
    validationClient.stageFailed(ValidationStage.FIND_RESOURCE, TERMINATE_TESTING, cmdWinOutput, FailureMode.SCHEDULER_PRODUCED_WARNING, [],[]);
    return;
end

validationClient.stageDone(ValidationStage.FIND_RESOURCE, cmdWinOutput, [], []);

if validationClient.isCancelledByClient()
    return;
end

% matlabpool is already in use?
client = distcomp.getInteractiveObject();
matlabpoolRunning = client.isPossiblyRunning();
if matlabpoolRunning
    % Must declare the MATLABPOOL stage to be running, so we can fail it:
    validationClient.stageRunning(ValidationStage.MATLABPOOL);
    validationClient.stageFailed(ValidationStage.MATLABPOOL, ~TERMINATE_TESTING, cmdWinOutput, FailureMode.MATLAB_POOL_UNAVAILABLE, [], []);
end

if validationClient.isCancelledByClient()
    return;
end


%% Step 2: Run a task-parallel (distributed) batch job:
% Note: This stage may fail by design, as with MPIexec schedulers, and 
% therefore will not terminate the validation.

iRunJobStage(scheduler, config, timeout, validationClient, ...
    ValidationStage.TASK_PARALLEL, @iCreateAndSubmitJob, ...
    @iGetLabInfoFromJob, @iGetErrorOutputFromJob, ~TERMINATE_TESTING);

if validationClient.isCancelledByClient()
    return;
end

% NOTE we still try a parallel job even if a distributed job fails as it
% might return some useful debugging info - hence no check of the return
% argument from iRunJobStage. Conversely, if a parallel job fails then the
% matlabpool job is never going to work, so no point trying

%% Step 3: Run a data-parallel (parallel) batch job:
completed = iRunJobStage(scheduler, config, timeout, validationClient, ...
    ValidationStage.DATA_PARALLEL, @iCreateAndSubmitParallelJob, ...
    @iGetLabInfoFromParallelJob, @iGetErrorOutputFromParallelJob, TERMINATE_TESTING);


if ~completed || validationClient.isCancelledByClient()
    return;
end

%% Step 4: Run a matlabpool:
if matlabpoolRunning
    return;
end

validationClient.stageRunning(ValidationStage.MATLABPOOL);

cmdWinOutput = '';
client = distcomp.getInteractiveObject();

% Set the clients startup timeout for matlabpool open (be careful to reset it later!):
origJobStartupTimeout = client.JobStartupTimeout;
client.JobStartupTimeout = timeout;

% Set the cleanup operation:
matlabpoolCleanup = onCleanup(@() iMatlabpoolCleanup(origJobStartupTimeout, config));

try
    openMatlabpoolFcn = @() matlabpool('open', config); %#ok<NASGU> - used in evalc
    cmdWinOutput = evalc('openMatlabpoolFcn()');
catch lastErr
    % The error may have been thrown as a result of the client
    % cancellation:
    if validationClient.isCancelledByClient()
        return;
    end
    % An exception is thrown if timeout reached while opening:
    if strcmp(lastErr.identifier, 'distcomp:interactive:TimeoutExceeded')
        validationClient.stageFailed(ValidationStage.MATLABPOOL, TERMINATE_TESTING, cmdWinOutput, FailureMode.TIMEOUT, iGetErrorReport(lastErr), []);
    else
        validationClient.stageFailed(ValidationStage.MATLABPOOL, TERMINATE_TESTING, cmdWinOutput, FailureMode.MATLAB_POOL_OPEN_ERROR, iGetErrorReport(lastErr), []);
    end
    
    return;
end

if validationClient.isCancelledByClient()
    return;
end
    
try
    parforFcn = @() iDoParfor(); %#ok<NASGU> - used in evalc
    [parforOutput, hostnames] = evalc('parforFcn()');
    cmdWinOutput = strcat(cmdWinOutput, parforOutput);
    
    closeMatlabpoolFcn = @() matlabpool('close', 'force', config); %#ok<NASGU> - used in evalc
    cmdWinOutput = strcat(cmdWinOutput, evalc('closeMatlabpoolFcn()'));
    validationClient.stageDone(ValidationStage.MATLABPOOL, cmdWinOutput, hostnames, []);
catch lastErr
    validationClient.stageFailed(ValidationStage.MATLABPOOL, TERMINATE_TESTING, cmdWinOutput, FailureMode.MATLAB_POOL_RUN_ERROR, iGetErrorReport(lastErr), []);
    return;
end

end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function iMatlabpoolCleanup(origJobStartupTimeout, config)
    client = distcomp.getInteractiveObject();

    % Close if still Open:
    if client.isPossiblyRunning()
        matlabpool('close', 'force', config);
    end

    client.JobStartupTimeout = origJobStartupTimeout;
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function hostnames = iDoParfor()
    session = com.mathworks.toolbox.distcomp.pmode.SessionFactory.getCurrentSession();
    numSessionLabs = session.getPoolSize();
    hostnames = cell(numSessionLabs, 1);
    parfor n = 1:numSessionLabs
        hostnames{n} = iGetLabInfo();
    end  
end
%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function job = iCreateAndSubmitJob(scheduler, config)
    job = createJob(scheduler, 'Configuration', config);
    try
        createTask(job, @iGetLabInfo, 1, {}, 'Configuration', config);
        submit(job);
    catch err
        % clean-up if problem creating task/submitting:
        job.destroy();
        rethrow(err);
    end
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function job = iCreateAndSubmitParallelJob(scheduler, config)
    job = createParallelJob(scheduler, 'Configuration', config);
    try
        createTask(job, @iGetLabInfo, 2, {}, 'Configuration', config);
        submit(job);
    catch err
        % clean-up if problem creating task/submitting:
        job.destroy();
        rethrow(err);
    end
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function [hostname, lab] = iGetLabInfo()
    cfg = pctconfig();
    hostname = cfg.hostname;
    lab = labindex;
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function [hostnames, labs] = iGetLabInfoFromJob(job)
    hostnames = job.getAllOutputArguments;
    labs = [];
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function [hostnames, labs] = iGetLabInfoFromParallelJob(job)
    outputArgs = job.getAllOutputArguments();
    hostnames = outputArgs(:,1);
    labs = outputArgs(:,2);
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function [errmsg, debugLog] = iGetErrorOutputFromJob(scheduler, job)
    errmsgs = get(job.Tasks, {'ErrorMessage'});
    
    % remove empty cells:
    errmsgs(cellfun(@isempty, errmsgs)) = '';
    
    %concat cell arr strings:
    errmsg = sprintf('%s\n', errmsgs{:});

    if ismethod(scheduler, 'getDebugLog')
        debugLog = getDebugLog(scheduler, job.Tasks);
    else
        debugLog = '';
    end
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function [errmsg, debugLog] = iGetErrorOutputFromParallelJob(scheduler, job)
    errmsgs = get(job.Tasks, {'ErrorMessage'});
    
    % remove empty cells:
    errmsgs(cellfun(@isempty, errmsgs)) = '';
    
    %concat cell arr strings:
    errmsg = sprintf('%s\n', errmsgs{:});

    if ismethod(scheduler, 'getDebugLog')
        debugLog = getDebugLog(scheduler, job);
    else
        debugLog = '';
    end
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function completed = iRunJobStage(scheduler, config, timeout, validationClient, stage, createAndSubmitFcn, getOutputFcn, getErrorFcn, isTerminal)  %#ok<INUSL> - used in evalc
    import com.mathworks.toolbox.distcomp.configui.validation.*;
    completed = false;

    % Return as unsupported if an MPIExec scheduler:
    if ValidationStage.TASK_PARALLEL.equals(stage) && scheduler.isa('distcomp.mpiexec')
        validationClient.stageUnsupported(stage);
        dctSchedulerMessage(1, 'Scheduler skipping task parallel: mpiexec scheduler does not currently support distributed jobs');
        return;
    end
    
    dctSchedulerMessage(1, 'Starting stage %s', char(stage));
    validationClient.stageRunning(stage);
    cmdWinOutput = '';
    try
        [cmdWinOutput, job] = evalc('createAndSubmitFcn(scheduler, config)');


        % By defining onCleanup in this block, will guarantee that the job
        % is destroyed when done:
        cleanup = onCleanup(@() destroy(job));
        
        waitTime = 0;
        jobFinished = false;

        % Break-up waitForState into short chunks to allow for validatorClient
        % to cancel:
        while ~validationClient.isCancelledByClient() && waitTime < timeout && ~jobFinished
            jobFinished = waitForState(job, 'finished', 1);
            waitTime = waitTime + 1;
        end

        % Check here to see if previous while loop terminated because client cancelled: 
        if validationClient.isCancelledByClient()
            dctSchedulerMessage(1, 'Client cancelled test.');
            return;
        end

        state = job.State;
        [errmsg, debugLog] = getErrorFcn(scheduler, job);
        
        % Did it complete with errors?
        hasErrs = ~isempty(errmsg);
        
        % Successful completion == 'finished' && no errors
        if strcmp(state, 'finished') && ~hasErrs
            [hostnames, labs] = getOutputFcn(job);
            validationClient.stageDone(stage, cmdWinOutput, hostnames, labs);
            completed = true;
        else
            if strcmp(state,'failed') || hasErrs
                validationClient.stageFailed(stage, isTerminal, cmdWinOutput, FailureMode.TASK_FAILED, errmsg, debugLog);
            % Job has timed-out:
            else    
                validationClient.stageFailed(stage, isTerminal, cmdWinOutput, FailureMode.TIMEOUT, errmsg, debugLog);
            end;
        end
    catch lastErr
        validationClient.stageFailed(stage, isTerminal, cmdWinOutput, FailureMode.JOB_ERROR, iGetErrorReport(lastErr), []);
    end

end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function iResetMatlabpoolOpenAllowed()
    com.mathworks.toolbox.distcomp.pmode.SessionFactory.sAllowedToStart.set(true);
end


%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function report = iGetErrorReport(err)
    report = err.getReport('basic','hyperlinks','off');
end

