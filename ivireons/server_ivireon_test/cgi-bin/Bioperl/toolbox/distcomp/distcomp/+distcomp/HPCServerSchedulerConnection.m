classdef HPCServerSchedulerConnection < distcomp.AbstractMicrosoftSchedulerConnection
    %HPCServerSchedulerConnection Class for connections to Microsoft HPC Server scheduler APIs
    %   Class for interfacing to Microsoft.Hpc.Scheduler.Scheduler.dll using
    %   MATLAB Interface to .NET Framework
    
    %  Copyright 2009-2010 The MathWorks, Inc.
    
    %  $Revision: 1.1.8.4 $  $Date: 2010/05/10 17:03:55 $
    
    properties (Dependent)
        UseSOAJobSubmission;
        JobTemplate;
    end
    
    properties (Constant, GetAccess = protected)
        % Keep track of whether or not we are on the correct platform.  This is required because
        % this class may be loaded by means other than findResource(...) (e.g. by the compiler or
        % by trying call methods(distcomp.HPCServerSchedulerConnection)
        % NB the order of these constants here isn't important.  The correct props will be 
        % loaded as required.
        IsCorrectPlatform = distcomp.HPCServerSchedulerConnection.isRunningOnCorrectPlatform();
        FoundSchedulerLibraries = distcomp.HPCServerSchedulerConnection.addAndCreateMicrosoftHpcScheduler();
        
        MicrosoftJobStates = distcomp.HPCServerSchedulerConnection.getMicrosoftJobStatesAsDouble();
        MatlabJobStates = distcomp.HPCServerSchedulerConnection.getMatlabJobStates();
        
        TaskStatesOKToCancel = distcomp.HPCServerSchedulerConnection.getOKToCancelTaskStates();
        JobStatesOKToCancel = distcomp.HPCServerSchedulerConnection.getOKToCancelJobStates();
    end
    
    properties (Access = private)
        % The actual connection to the HPC Server 2008 API.  This is an .NET object
        % of type Microsoft.Hpc.Scheduler.Scheduler
        HPCSchedulerConnection;
        % The connection to the SOA client for HPC Server 2008.  This is an object
        % of type AbstractHPCServerSOAConnection
        SOAConnection;
        % Private UseSOA to support the dependent UseSOAJobSubmission property
        PrivateUseSOAJobSubmission = distcomp.HPCServerSchedulerConnection.DoNotUseSOAJobSubmission;
        % Private JobTemplate to support the dependent JobTemplate property
        PrivateJobTemplate = distcomp.HPCServerSchedulerConnection.EmptyJobTemplate;
    end
    
    properties (Constant, GetAccess = private)
        EmptyJobTemplate = '';
        DoNotUseSOAJobSubmission = false;
    end
    
    
    methods (Static)% AbstractMicrosoftSchedulerConnection Abstract, static method implementation
        %---------------------------------------------------------------
        % getAPIVersion
        %---------------------------------------------------------------
        function version = getAPIVersion
            % NB This needs to be a string that matches the value
            % of distcomp.microsoftclusterversion
            version = 'HPCServer2008';
        end

        %---------------------------------------------------------------
        % testClientCompatibilityWithMicrosoftAPI
        %---------------------------------------------------------------
        % Test whether or not Microsoft.Hpc.Scheduler.Scheduler can be 
        % constructed.  
        function isCompatible = testClientCompatibilityWithMicrosoftAPI
            isCompatible = distcomp.HPCServerSchedulerConnection.FoundSchedulerLibraries;
        end
    end
    
    methods (Static, Access = private) % Methods to support Constant, protected properties.
        % Methods in this section should NEVER be called directly - use the constant properties instead.
        
        %---------------------------------------------------------------
        % isRunningOnCorrectPlatform
        %---------------------------------------------------------------
        function isCorrectPlatform = isRunningOnCorrectPlatform
            % Currently only supported on win64
            isCorrectPlatform = strcmpi(computer('arch'), 'win64');
        end
        
        %---------------------------------------------------------------
        % addAndCreateMicrosoftHpcScheduler
        %---------------------------------------------------------------
        % NB This will only get called once by the constant FoundSchedulerLibraries
        % property.  FoundSchedulerLibraries will "persist" until
        % "clear classes" is called.
        function success = addAndCreateMicrosoftHpcScheduler
            % Return early if we aren't on the correct platform
            if ~distcomp.HPCServerSchedulerConnection.IsCorrectPlatform
                success = false;
                return;
            end
            
            try
                NET.addAssembly('Microsoft.Hpc.Scheduler');
                NET.addAssembly('Microsoft.Hpc.Scheduler.Properties');
                % See if we can create a .NET connection to the scheduler
                testObj = Microsoft.Hpc.Scheduler.Scheduler;
                % Make sure we dispose of it as well
                testObj.Dispose();
                success = true;
            catch err %#ok<NASGU>
                success = false;
            end
        end
        
        %---------------------------------------------------------------
        % getMicrosoftJobStatesAsDouble
        %---------------------------------------------------------------
        % NB This will only get called once by the constant MicrosoftJobStates
        % property.  distcomp.MicrosoftJobStates will "persist" until
        % "clear classes" is called.
        function jobStates = getMicrosoftJobStatesAsDouble
            % Return empty if Microsoft.Hpc.Scheduler.dll hasn't been loaded.
            if ~distcomp.HPCServerSchedulerConnection.FoundSchedulerLibraries
                jobStates = [];
                return;
            end
            
            try
                import Microsoft.Hpc.Scheduler.Properties.*
                % Map the job states to values in distcomp.jobexecutionstate.
                % NB Ensure that all the job states listed in
                % http://msdn.microsoft.com/en-us/library/microsoft.hpc.scheduler.properties.jobstate(VS.85).aspx
                % appear here.
                jobStates = [
                    double(JobState.Canceled); ...              %'finished'; ...
                    double(JobState.Canceling); ...             %'finished'; ...
                    double(JobState.Configuring); ...           %'queued'; ...
                    double(JobState.ExternalValidation); ...    %'queued'; ...
                    double(JobState.Failed); ...                %'failed'; ...
                    double(JobState.Finished); ...              %'finished'; ...
                    double(JobState.Finishing); ...             %'finished'; ...
                    double(JobState.Queued); ...                %'queued'; ...
                    double(JobState.Running); ...               %'running'; ...
                    double(JobState.Submitted); ...             %'queued'; ...
                    double(JobState.Validating); ...            %'queued'; ...
                    ];
            catch err
                % Really shouldn't ever get in here because we've already checked
                % if Microsoft.Hpc.Scheduler.dll is loaded
                dctSchedulerMessage(5, 'Failed to get job states from Microsoft.Hpc.Scheduler.Properties.\nReason: %s', ...
                    err.getReport());
            end
        end
        
        %---------------------------------------------------------------
        % getDistcompJobStates
        %---------------------------------------------------------------
        % NB This will only get called once by the constant MatlabJobStates
        % property.  distcomp.MatlabJobStates will "persist" until
        % "clear classes" is called.
        function jobStates = getMatlabJobStates
            % NB The states listed here MUST match the order of the states
            % listed in the getMicrosoftJobStatesAsDouble function!
            jobStates = {
                'finished'; ...     %double(JobState.Canceled),
                'finished'; ...     %double(JobState.Canceling),
                'queued'; ...       %double(JobState.Configuring),
                'queued'; ...       %double(JobState.ExternalValidation),
                'failed'; ...       %double(JobState.Failed),
                'finished'; ...     %double(JobState.Finished),
                'finished'; ...     %double(JobState.Finishing),
                'queued'; ...       %double(JobState.Queued),
                'running'; ...      %double(JobState.Running),
                'queued'; ...       %double(JobState.Submitted),
                'queued'; ...       %double(JobState.Validating),
                };
        end
        
        %---------------------------------------------------------------
        % getOKToCancelTaskStates
        %---------------------------------------------------------------
        % NB This will only get called once by the constant TaskStatesOKToCancel
        % property.  distcomp.TaskStatesOKToCancel will "persist" until
        % "clear classes" is called.
        function taskStateOKToCancel = getOKToCancelTaskStates
            % Return empty if Microsoft.Hpc.Scheduler.dll hasn't been loaded.
            if ~distcomp.HPCServerSchedulerConnection.FoundSchedulerLibraries
                taskStateOKToCancel = [];
                return;
            end
            
            try
                import Microsoft.Hpc.Scheduler.Properties.*
                % From http://msdn.microsoft.com/en-us/library/microsoft.hpc.scheduler.ischedulerjob.canceltask(VS.85).aspx
                % To cancel a task, the state of the task must be: Configuring, Submitted, Queued, or Running
                taskStateOKToCancel = [
                    double(TaskState.Configuring); ...
                    double(TaskState.Submitted); ...
                    double(TaskState.Queued); ...
                    double(TaskState.Running)];
            catch err
                % Really shouldn't ever get in here because we've already checked
                % if Microsoft.Hpc.Scheduler.dll is loaded
                dctSchedulerMessage(5, 'Failed to get task states from Microsoft.Hpc.Scheduler.Properties.\nReason: %s', ...
                    err.getReport());
            end
        end
        
        %---------------------------------------------------------------
        % getOKToCancelJobStates
        %---------------------------------------------------------------
        % NB This will only get called once by the constant JobStatesOKToCancel
        % property.  distcomp.JobStatesOKToCancel will "persist" until
        % "clear classes" is called.
        function jobStateOKToCancel = getOKToCancelJobStates
            % Return empty if Microsoft.Hpc.Scheduler.dll hasn't been loaded.
            if ~distcomp.HPCServerSchedulerConnection.FoundSchedulerLibraries
                jobStateOKToCancel = [];
                return;
            end
            
            try
                import Microsoft.Hpc.Scheduler.Properties.*
                % Only cancel the job if the scheduler thinks it's not finished
                % From http://msdn.microsoft.com/en-us/library/microsoft.hpc.scheduler.ischeduler.canceljob(VS.85).aspx
                % To cancel a job, the state of the job must be
                % configuring, submitted, validating, queued, or running.
                jobStateOKToCancel = [
                    double(JobState.Configuring); ...
                    double(JobState.Submitted); ...
                    double(JobState.Validating); ...
                    double(JobState.Queued); ...
                    double(JobState.Running)];
            catch err
                % Really shouldn't ever get in here because we've already checked
                % if Microsoft.Hpc.Scheduler.dll is loaded
                dctSchedulerMessage(5, 'Failed to get job states from Microsoft.Hpc.Scheduler.Properties.\nReason: %s', ...
                    err.getReport());
            end
        end
    end
    
    methods
        %---------------------------------------------------------------
        % Constructor
        %---------------------------------------------------------------
        function obj = HPCServerSchedulerConnection
            if ~obj.FoundSchedulerLibraries
                error(sprintf('distcomp:HPCServerSchedulerConnection:%s', ...
                    distcomp.MicrosoftSchedulerConnectionExceptionManager.UnableToContactServiceErrorID), ...
                    'It appears that Microsoft HPC Server 2008 is not installed on this machine.');
            end
            
            % See if we can create a .NET connection to the scheduler
            try
                obj.HPCSchedulerConnection = Microsoft.Hpc.Scheduler.Scheduler;
                % Tell the scheduler that MATLAB is not a console application - this ensures
                % that the password prompt dialog is displayed (if the user's credentials
                % aren't cached).  The default interface mode is console, which causes MATLAB
                % to appear as if it has hung because the prompt has disappeared to the "console"
                % which doesn't really exist.
                obj.HPCSchedulerConnection.SetInterfaceMode(obj.IsConsoleApplication, ...
                    System.IntPtr(obj.ParentWindow));
            catch err
                ex = MException(sprintf('distcomp:HPCServerSchedulerConnection:%s', ...
                    distcomp.MicrosoftSchedulerConnectionExceptionManager.UnableToContactServiceErrorID), ...
                    'It appears that Microsoft HPC Server 2008 is not installed on this machine');
                ex = ex.addCause(err);
                throw(ex);
            end
        end
        
        %---------------------------------------------------------------
        % Delete
        %---------------------------------------------------------------
        function delete(obj)
            % Dispose of the .NET scheduler connection
            % Note that .NET Dispose functions should never throw exceptions
            % Note: obj.HPCSchedulerConnection will never be empty, but
            % obj.SOAConnection may be empty if we couldn't create an SOA client.
            if ~isempty(obj.HPCSchedulerConnection) && isa(obj.HPCSchedulerConnection, 'System.IDisposable')
                obj.HPCSchedulerConnection.Dispose();
            end
        end
        
        %---------------------------------------------------------------
        % get.UseSOAJobSubmission
        %---------------------------------------------------------------
        function useSOA = get.UseSOAJobSubmission(obj)
            % just defer to the Private property
            useSOA = obj.PrivateUseSOAJobSubmission;
        end
        
        %---------------------------------------------------------------
        % set.UseSOAJobSubmission
        %---------------------------------------------------------------
        function set.UseSOAJobSubmission(obj, useSOA)
            % If useSOA is false, then we can always set it.
            % If useSOA is true AND we are not connected, then we don't know if SOA is supported
            % If useSOA is true AND we are connected AND there is no SOA connection, then warn that
            % SOA is not supported and default it back to false.
            % In all other circumstances, just set the useSOA value as requested.
            if useSOA
                if ~obj.IsConnected
                    % Not connected, so we can't check if SOA jobs are supported
                    % No warning here - let connect method deal with it.
                elseif obj.IsConnected && isempty(obj.SOAConnection)
                    warning('distcomp:HPCServerSchedulerConnection:SOANotSupported', ...
                        'SOA Jobs are not supported on this scheduler.  Defaulting to non SOA jobs');
                    useSOA = false;
                end
            end
            obj.PrivateUseSOAJobSubmission = useSOA;
        end
        
        %---------------------------------------------------------------
        % set.JobTemplate
        %---------------------------------------------------------------
        function set.JobTemplate(obj, jobTemplate)
            if ~isempty(jobTemplate)
                if obj.IsConnected
                    % Check if the specified job template is a valid one
                    allJobTemplates = obj.HPCSchedulerConnection.GetJobTemplateList;
                    % Convert StringCollection to a cell array of strings
                    allJobTemplateNames = cell(allJobTemplates.Count, 1);
                    for i = 1:allJobTemplates.Count
                        allJobTemplateNames{i} = char(allJobTemplates.Item(i-1));
                    end
                    
                    if ~any(strcmpi(allJobTemplateNames, jobTemplate))
                        error(sprintf('distcomp:HPCServerSchedulerConnection:%s', ...
                            distcomp.MicrosoftSchedulerConnectionExceptionManager.InvalidJobTemplateErrorID), ...
                            '%s is not a valid job template for this scheduler.', jobTemplate);
                    end
                else
                    % Not connected, so we can't check if the job template is valid.
                    % Warn that this may mean that any jobs that are submitted using
                    % this connection may not be submitted correctly.
                    warning('distcomp:HPCServerSchedulerConnection:CannotVerifyJobTemplate', ...
                        ['Cannot determine if %s is a valid job template name because the server connection is not connected to a scheduler.\n', ...
                        'You may not be able to submit jobs using this server connection.'], ...
                        jobTemplate);
                end
            end
            
            % Set the private job template property
            obj.PrivateJobTemplate = jobTemplate;
        end
        
        %---------------------------------------------------------------
        % get.JobTemplate
        %---------------------------------------------------------------
        function jobTemplate = get.JobTemplate(obj)
            % defer to the private property
            jobTemplate = obj.PrivateJobTemplate;
        end
    end
    
    methods % AbstractMicrosoftSchedulerConnection Abstract, public method implementation
        %---------------------------------------------------------------
        % connect
        %---------------------------------------------------------------
        % NB Limit the number of times Connect is called since this
        % leaks a thread every time a connection is made (even if you
        % connect to the same scheduler again).
        %
        % Note that once we have connected successfully, we will stay
        % connected to that scheduler.
        function connect(obj, schedulerHostname)
            if obj.isConnectedToScheduler(schedulerHostname)
                % Already connected to that scheduler
                return;
            end
            
            try
                obj.HPCSchedulerConnection.Connect(schedulerHostname);
                % NB must set the hostname and version when we successfully connect
                obj.SchedulerVersion = obj.getVersionFromScheduler;
                obj.SchedulerHostname = schedulerHostname;
                % Indicate that we've connected at least once
                obj.HaveSuccessfullyConnectedOnce = true;
            catch err
                % Throw an error
                ex = MException('distcomp:HPCSchedulerConnection:UnableToConnect', ...
                    'Unable to contact an HPC scheduler on machine %s', schedulerHostname);
                ex = ex.addCause(err);
                throw(ex)
            end
            
            % Try to create the SOA connection with the highest version first.  If that 
            % errors, we'll progressively downgrade.
            import parallel.internal.cluster.*
            if HPCServer2008R2SOAConnection.isClientCompatible(obj.SchedulerVersion)
                obj.SOAConnection = HPCServer2008R2SOAConnection(obj.HPCSchedulerConnection, obj.SchedulerHostname);
            elseif HPCServer2008SOAConnection.isClientCompatible(obj.SchedulerVersion)
                obj.SOAConnection = HPCServer2008SOAConnection(obj.HPCSchedulerConnection, obj.SchedulerHostname);
            else
                if obj.UseSOAJobSubmission
                    % Just warn here rather than erroring as we may not want to submit SOA jobs anyway.
                    warning('distcomp:HPCSchedulerConnection:UnableToConnectSOAClient', ...
                        ['Cannot create a suitable SOA client for scheduler version %d.\n', ...
                        'You will be unable to submit SOA jobs to the scheduler with hostname %s.'], ...
                        obj.SchedulerVersion, obj.SchedulerHostname);
                end	
                obj.UseSOAJobSubmission = obj.DoNotUseSOAJobSubmission;
            end
            
            % Always set the Maxmimum number of workers to a sensible value when
            % connecting to a new cluster
            obj.MaximumNumberOfWorkersPerJob = obj.TotalNumberOfCores;
            
            % Use the set method for the JobTemplate property to check if the 
            % JobTemplate is still valid.  It is OK to call the set method now
            % because HaveSuccessfullyConnectedOnce has already been set to true.
            oldJobTemplateValue = obj.JobTemplate;
            try
                % Set Job template to empty first before restoring the old value
                % to guard against AbortSet = On.
                obj.JobTemplate = obj.EmptyJobTemplate;
                obj.JobTemplate = oldJobTemplateValue;
            catch err %#ok<NASGU>
                warning(sprintf('distcomp:HPCServerSchedulerConnection:%s', ...
                    distcomp.MicrosoftSchedulerConnectionExceptionManager.InvalidJobTemplateErrorID), ...
                    '%s is not a valid job template for scheduler with name %s.  Setting the JobTemplate to empty.', ...
                    oldJobTemplateValue, obj.SchedulerHostname);
                obj.JobTemplate = obj.EmptyJobTemplate;
            end
        end
        
        %---------------------------------------------------------------
        % submitJob
        %---------------------------------------------------------------
        % NB Assumes that the job has already been prepared for submission
        %
        % job                                   distcomp.abstractjob
        % matlabExe                             the matlab executable that should be run
        % matlabArgs                            the command line arguments for the matlabExe
        % jobEnvironmentVariables               all the environment variables that are common for the distributed job
        % taskLocationEnvironmentVariableName   the name of the environment variable to use for the task location
        % jobLocation                           the full path to the job location
        % logLocationTemplate                   template for the task log location.  The token 'logTaskIDToken' will be
        %                                       replaced with the actual task ID
        % logTaskIDToken                        the string token that needs to be replaced in the logLocationTemplate
        %                                       with the actual task ID.
        % username                              the username which will be used to launch the matlab processes
        % password                              the password associated with the username (an empty string will
        %                                       cause the user to be prompted to enter a password).
        function [schedulerJobIDs, schedulerTaskIDs, schedulerJobName] = submitJob(obj, job, matlabExe, matlabArgs, ...
                jobEnvironmentVariables, taskLocationEnvironmentVariableName, ...
                jobLocation, logLocationTemplate, logTaskIDToken, ...
                username, password)
            obj.errorIfNotConnected;
            
            if obj.UseSOAJobSubmission
                [schedulerJobIDs, schedulerTaskIDs, schedulerJobName] = submitSOAJob(obj, job, ...
                    matlabExe, matlabArgs, ...
                    jobEnvironmentVariables, ...
                    jobLocation, logLocationTemplate, logTaskIDToken, ...
                    username, password);
            else
                [schedulerJobIDs, schedulerTaskIDs, schedulerJobName] = submitNonSOAJob(obj, job, ...
                    matlabExe, matlabArgs, ...
                    jobEnvironmentVariables, taskLocationEnvironmentVariableName, ...
                    logLocationTemplate, logTaskIDToken, ...
                    username, password);
            end
        end
        
        %---------------------------------------------------------------
        % submitParallelJob
        %---------------------------------------------------------------
        function [schedulerJobIDs, schedulerTaskIDs] = submitParallelJob(obj, job, taskCommandToRun, ...
                jobEnvironmentVariables, logLocation, ...
                username, password)
            obj.errorIfNotConnected;
            
            % Ensure we have enough processors on the cluster.
            % NB we can only find out the total number of cores that are physically
            % available on the cluster - they may not all be configured as "compute
            % cores".  Furthermore, the job template may limit the maximum number of
            % cores that can get allocated.
            minProcessors = job.MinimumNumberOfWorkers;
            maxProcessors = job.MaximumNumberOfWorkers;
            totalCores = obj.TotalNumberOfCores;
            assert(totalCores >= minProcessors, 'distcomp:CCSSchedulerConnection:ResourceLimit', ...
                'The job has requested %d workers. The HPC Server scheduler only has %d cores in the cluster', ...
                minProcessors, totalCores);
            
            % Create a new job
            hpcsJob = obj.createJobOnScheduler;
            % Always set the requested number of processors for parallel jobs
            hpcsJob.MaximumNumberOfCores = maxProcessors;
            hpcsJob.MinimumNumberOfCores = minProcessors;
            % Leave IsExclusive unset on the job - let the XML or Job Template take care of this
            
            % All tasks will attach to task 1 on the scheduler
            tasks = job.Tasks;
            numTasks = numel(tasks);
            schedulerTaskIDs = ones(numTasks, 1);
            
            % Create the one parallel task
            t = hpcsJob.CreateTask();
            % Set the requested number of processors
            t.MaximumNumberOfCores = maxProcessors;
            t.MinimumNumberOfCores = minProcessors;
            % Neither the job XML nor job template defines IsExclusive on a task, so set it here
            % This ensures that multiple tasks from the same job can run on the same node.
            t.IsExclusive = obj.DoNotUseResourcesExclusively;
            
            % Now set the environment variables
            for k = 1:size(jobEnvironmentVariables, 1)
                t.SetEnvironmentVariable(jobEnvironmentVariables{k, 1}, jobEnvironmentVariables{k, 2});
            end
            
            if ~isempty(logLocation)
                % Redirect stdout and stderr to the log
                t.StdOutFilePath = logLocation;
                t.StdErrFilePath = logLocation;
            end
            
            t.CommandLine = taskCommandToRun;
            
            % Now add the task to the job
            hpcsJob.AddTask(t);
            
            % The V2 API has a bug such that if the password is an zero length string,
            % the credentials will not be retrieved from the cache, and the user is
            % prompted to enter their password every single time.  Setting the password
            % to [] (i.e. a null string) means that the cached credentials are correctly
            % used.
            if strcmpi(password, '')
                password = [];
            end
            % Set the credentials for the job and submit the job
            obj.HPCSchedulerConnection.SubmitJob(hpcsJob, username, password);
            
            % Only one ccs job ID for v1 jobs.
            schedulerJobIDs = double(hpcsJob.Id);
        end
        
        %---------------------------------------------------------------
        % cancelTaskByID
        %---------------------------------------------------------------
        % Cancel the specified task in the specified job on HPCS.  The jobID and taskID
        % are HPCS's IDs.
        function cancelTaskByID(obj, jobID, taskID)
            obj.errorIfNotConnected;
            
            job = obj.getJobByID(jobID);
            dotnetTaskID = Microsoft.Hpc.Scheduler.Properties.TaskId(taskID);
            try
                t = job.OpenTask(dotnetTaskID);
            catch err
                ex = MException('distcomp:HPCServerSchedulerConnection:UnableToFindTask', ...
                    'Unable to find task %d for job %d.', taskID, jobID);
                ex = ex.addCause(err);
                throw(ex);
            end
            
            isOKToCancel = any(obj.TaskStatesOKToCancel == double(t.State));
            if isOKToCancel
                % Now cancel the task
                job.CancelTask(dotnetTaskID);
            end
        end
        
        %---------------------------------------------------------------
        % getJobStateByID
        %---------------------------------------------------------------
        % Get the state of the specified job.  The jobID is the HPCS job ID.
        function state = getJobStateByID(obj, jobID)
            obj.errorIfNotConnected;
            j = obj.getJobByID(jobID);
            
            stateIndex = obj.MicrosoftJobStates == double(j.State);
            if ~any(stateIndex)
                % Just being paranoid.  Shouldn't get here.
                error('distcomp:HPCServerSchedulerConnection:getJobStateByID', ...
                    'HPC Server returned an unknown job status for job %d.', jobID);
            end
            state = obj.MatlabJobStates{stateIndex};
        end
        
        %---------------------------------------------------------------
        % getSchedulerDetailsForFailedJob
        %---------------------------------------------------------------
        % Get job details from HPCS for the specified job and task IDs.
        % Returns a string for use in debug logs.  The jobID and taskID are
        % HPCS's IDs.  TaskID is an optional input argument.
        function jobDetails = getSchedulerDetailsForFailedJob(obj, jobID, taskID)
            obj.errorIfNotConnected;
            if nargin < 2
                taskID = [];
            end
            
            % Start with the error message for the job
            try
                job = obj.getJobByID(jobID);
            catch err %#ok<NASGU>
                jobDetails = sprintf('Unable to retrieve job %d from the scheduler', jobID);
                return;
            end
            
            cellout{1} = sprintf('Getting data for HPC Server 2008 JobID %d\n', jobID);
            cellout{2} = sprintf('Error Message : %s\n', char(job.ErrorMessage));
            
            if ~isempty(taskID)
                % Need to use the fully namespaced name for TaskId,
                % otherwise it doesn't seem to work.
                dotnetTaskID = Microsoft.Hpc.Scheduler.Properties.TaskId(taskID);
                try
                    % job.OpenTask will throw an error if the task doesn't exist
                    % for this job
                    ccsTask = job.OpenTask(dotnetTaskID);
                    cellout{3} = sprintf('Getting data for HPC Server 2008 JobID %d and TaskID %d\n', jobID, taskID);
                    % NB need to convert all System.Strings into char arrays.
                    cellout{4} = sprintf('CommandLine   : %s\n', char(ccsTask.CommandLine));
                    cellout{5} = sprintf('Stdout sent   : %s\n', char(ccsTask.StdOutFilePath));
                    cellout{6} = sprintf('Error Message : %s\n', char(ccsTask.ErrorMessage));
                catch err %#ok<NASGU>
                    cellout{end+1} = sprintf('Unable to retrieve task %d for job %d from the scheduler', taskID, jobID);
                end
            end
            jobDetails = sprintf('%s', cellout{:});
        end
    end
    
    methods % AbstractMicrosoftSchedulerConnection overrides
        %---------------------------------------------------------------
        % cancelJob
        %---------------------------------------------------------------
        function cancelJob(obj, jobSchedulerData)
            obj.errorIfNotConnected;
            
            % If the job was an SOA job, then ensure that we close the SOA client
            if jobSchedulerData.IsSOAJob && ~isempty(obj.SOAConnection)
                try
                    obj.SOAConnection.closeJob(jobSchedulerData.SchedulerJobID, ...
                        jobSchedulerData.SchedulerJobName);
                catch err
                    warning('distcomp:HPCServerSchedulerConnection:closeSoaClient', ...
                        'Unable to close SOA client.  Reason given:\n%s', err.message);
                end
            end
            
            % Call the AbstractMicrosoftSchedulerConnection cancel Job method to cancel the
            % jobs on the scheduler. (Note that closing the SOA client may already have
            % cancelled the jobs if the SOA had already started to run.  If the job
            % was still in the queued state, then closing the job on the SOA client will not cancel
            % the actual jobs.)
            cancelJob@distcomp.AbstractMicrosoftSchedulerConnection(obj, jobSchedulerData);
        end
    end
    
    methods (Access = protected) % AbstractMicrosoftSchedulerConnection Abstract, protected method implementation
        %---------------------------------------------------------------
        % getHostnameFromScheduler.  Returns the hostname as a MATLAB char array
        %---------------------------------------------------------------
        function hostname = getHostnameFromScheduler(obj)
            % BEWARE: A scheduler that has not been connected will throw an error when
            % GetNodesInNodeGroup (or pretty much any other method) is called.  Once this
            % has occurred, subsequent calls to GetNodesInNodeGroup after connection will
            % also throw an error.
            
            % Hacky way to get the scheduler hostname due to the lack of a "Name" property in v2.
            try
                allHeadNodes = obj.HPCSchedulerConnection.GetNodesInNodeGroup('HeadNodes');
            catch err
                ex = MException('distcomp:HPCServerSchedulerConnection:UnableToFindHeadNode', ...
                    'Failed to find HeadNodes node group on scheduler.');
                ex = ex.addCause(err);
                throw(ex);
            end
            
            % Expect more than 0 headnodes
            if allHeadNodes.Count < 1
                error('distcomp:HPCServerSchedulerConnection:UnableToFindHeadNode', ...
                    'Found no nodes in the HeadNodes group.');
            end
            % Use the first in the array for now.
            dotnetHostname = allHeadNodes.Item(0); % zero-based indexing for .NET types
            % convert from System.String to a char array
            hostname = char(dotnetHostname);
        end
        
        %---------------------------------------------------------------
        % getVersionFromScheduler
        %---------------------------------------------------------------
        % Get the scheduler version from the server connection.
        function version = getVersionFromScheduler(obj)
            try
                dotnetSchedulerVersion = obj.HPCSchedulerConnection.GetServerVersion().Major;
            catch err
                ex = MException('distcomp:HPCServerSchedulerConnection:UnableToGetServerVersion', ...
                    'Failed to retrieve server version from scheduler.');
                ex = ex.addCause(err);
                throw(ex);
            end
            
            % convert from .NET to MATLAB type
            version = double(dotnetSchedulerVersion);
        end
        
        %---------------------------------------------------------------
        % getTotalCores
        %---------------------------------------------------------------
        % Gets the total number of cores in the cluster.
        % Note that this value represents the actual number of cores in the cluster
        % and does not provide any information about how many cores actually belong
        % to compute nodes.
        function totalCores = getTotalCores(obj)
            counters = obj.HPCSchedulerConnection.GetCounters;
            totalCores = double(counters.TotalCores);
        end
        
        %---------------------------------------------------------------
        % cancelJobsByID
        %---------------------------------------------------------------
        % Cancel the specified job on HPCS.  jobID is a vector of HPCS job IDs.
        function cancelJobsByID(obj, jobID)
            if isempty(jobID)
                return;
            end
            
            numJobsToCancel = length(jobID);
            allErrors = {};
            allErroredJobIds = -ones(numJobsToCancel, 1);
            for i = 1:numJobsToCancel
                currJobID = jobID(i);
                try
                    ccsJob = obj.getJobByID(currJobID);
                    isOKToCancel = any(obj.JobStatesOKToCancel == double(ccsJob.State));
                    
                    if isOKToCancel
                        % And cancel the job
                        cancellationMessage = '';
                        obj.HPCSchedulerConnection.CancelJob(currJobID, cancellationMessage);
                    end
                catch err
                    % Save up the errors for a MultipleException later
                    allErroredJobIds(i) = currJobID;
                    allErrors = [allErrors; err]; %#ok<AGROW>
                end
            end
            
            % Now throw the errors that were caught during the cancellation
            if ~isempty(allErrors)
                actualErroredJobIds = allErroredJobIds(allErroredJobIds ~= -1);
                errorString = sprintf('Failed to cancel the following job(s) on scheduler:%s', ...
                    sprintf(' %d', actualErroredJobIds));
                throw(distcomp.MultipleException(allErrors, errorString));
            end
        end
        
        %---------------------------------------------------------------
        % createJobOnScheduler
        %---------------------------------------------------------------
        % Create a new job on the scheduler, applying the job XML Description file
        % and Job Template, if appropriate
        function schedulerJob = createJobOnScheduler(obj)
            % Create a new job
            schedulerJob = obj.HPCSchedulerConnection.CreateJob();
            % If an XML file is defined, then restore the job from the XML.
            % DO THIS IMMEDIATELY AFTER CREATING THE JOB: RestoreFromXml OVERWRITES
            % ALL JOB PROPERTIES.
            if ~isempty(obj.JobDescriptionFile)
                try
                    schedulerJob.RestoreFromXml(obj.JobDescriptionFile);
                catch err
                    ex = MException(sprintf('distcomp:HPCServerSchedulerConnection:%s', ...
                        distcomp.MicrosoftSchedulerConnectionExceptionManager.FailedToCreateJobFromXMLErrorID), ...
                        'Failed to create job from xml file %s', obj.JobDescriptionFile);
                    ex = ex.addCause(err);
                    throw(ex);
                end
            end
            % Set the job template, if available.
            if ~isempty(obj.JobTemplate)
                try
                    schedulerJob.SetJobTemplate(obj.JobTemplate);
                catch err
                    ex = MException(sprintf('distcomp:HPCServerSchedulerConnection:%s', ...
                        distcomp.MicrosoftSchedulerConnectionExceptionManager.FailedToUseJobTemplateErrorID), ...
                        'Failed to use job template %s on job.', obj.JobTemplate);
                    ex = ex.addCause(err);
                    throw(ex);
                end
            end
        end
    end
    
    methods  (Access = protected)
        %---------------------------------------------------------------
        % getJobByID
        %---------------------------------------------------------------
        function job = getJobByID(obj, jobID)
            try
                job = obj.HPCSchedulerConnection.OpenJob(jobID);
            catch err
                ex = MException('distcomp:HPCServerSchedulerConnection:UnableToRetrieveJob', ...
                    'Unable to retrieve job %d from the scheduler', jobID);
                ex = ex.addCause(err);
                throw(ex);
            end
        end
        
        %---------------------------------------------------------------
        % submitNonSOAJob
        %---------------------------------------------------------------
        function [schedulerJobIDs, schedulerTaskIDs, schedulerJobName] = submitNonSOAJob(obj, job, ...
                matlabExe, matlabArgs, ...
                jobEnvironmentVariables, taskLocationEnvironmentVariableName, ...
                logLocationTemplate, logTaskIDToken, ...
                username, password)
            % Job Name is used only for SOA v2 jobs
            schedulerJobName = '';
            tasks = job.Tasks;
            numTasks = numel(tasks);
            matlabCommand = sprintf('"%s" %s', matlabExe,  matlabArgs);
            
            hpcsJob = obj.createJobOnScheduler;
            % Don't set the min and max resource usage nor the IsExclusive property.
            % Defer to the values in the job template instead. If no job template
            % is explicitly specified, then the scheduler will use the default job template.
            
            % For each task add the task to the job and set the environment variables
            schedulerTaskIDs = zeros(numTasks, 1);
            for i = 1:numTasks
                % Create the task
                t = hpcsJob.CreateTask();
                
                taskLocation = tasks(i).pGetEntityLocation;
                % Now set the common environment variables
                for k = 1:size(jobEnvironmentVariables, 1)
                    t.SetEnvironmentVariable(jobEnvironmentVariables{k, 1}, jobEnvironmentVariables{k, 2});
                end
                % Additional task-specific environment variables
                t.SetEnvironmentVariable(taskLocationEnvironmentVariableName, taskLocation);
                
                % Set any other options that we want set
                logLocation = strrep(logLocationTemplate, logTaskIDToken, num2str(tasks(i).ID));
                % Redirect stdout and stderr to the log
                t.StdOutFilePath = logLocation;
                t.StdErrFilePath = logLocation;
                
                % Neither the job XML nor job template defines IsExclusive on a task, so set it here.
                % This ensures that multiple tasks from the same job can run on the same node.
                t.IsExclusive = obj.DoNotUseResourcesExclusively;
                t.CommandLine = matlabCommand;
                
                % Now add the task to the job
                hpcsJob.AddTask(t);
                % NOTE - CCS doesn't actually know the ID of it's task at this point so
                % we will assume it grows monotonically from 1
                schedulerTaskIDs(i) = i;
            end
            
            % The V2 API has a bug such that if the password is an zero length string,
            % the credentials will not be retrieved from the cache, and the user is
            % prompted to enter their password every single time.  Setting the password
            % to [] (i.e. a null string) means that the cached credentials are correctly
            % used.
            if strcmpi(password, '')
                password = [];
            end
            % Set the credentials for the job and submit the job
            obj.HPCSchedulerConnection.SubmitJob(hpcsJob, username, password);
            
            % Only one ccs job ID for v1 jobs.
            schedulerJobIDs = double(hpcsJob.Id);
        end
        
        %---------------------------------------------------------------
        % submitSOAJob
        %---------------------------------------------------------------
        function [schedulerJobIDs, schedulerTaskIDs,schedulerJobName] = submitSOAJob(obj, job, ...
                matlabExe, matlabArgs, ...
                jobEnvironmentVariables, ...
                jobLocation, logLocationTemplate, logTaskIDToken, ...
                username, password)

            assert(~isempty(obj.SOAConnection), ...
                'distcomp:HPCServerSchedulerConnection:CannotSubmitSOAJob', ...
                'Cannot submit SOA jobs because there is no SOA connection.');
            
            % Scheduler's task IDs are always empty for SOA jobs
            schedulerTaskIDs = [];
            
            % convert the task stuff into arrays
            tasks = job.Tasks;
            numTasks = numel(tasks);
            taskIDs = zeros(numTasks, 1);
            taskLocations = cell(numTasks, 1);
            taskLogLocations = cell(numTasks, 1);
            for ii = 1:numTasks
                taskIDs(ii) = tasks(ii).ID;
                taskLocations{ii} = tasks(ii).pGetEntityLocation;
                % Set any other options that we want set
                taskLogLocations{ii} = strrep(logLocationTemplate, logTaskIDToken, num2str(tasks(ii).ID));
            end
            
            try
                [schedulerJobIDs, schedulerJobName] = obj.SOAConnection.submitJob(...
                    job.ID, jobLocation, taskIDs, taskLocations, taskLogLocations, obj.JobTemplate, ...
                    matlabExe, matlabArgs, jobEnvironmentVariables, username, password);
            catch err
                ex = MException('distcomp:HPCServerSchedulerConnection:CannotSubmitSOAJob', ...
                    'Error occurred when submitting SOA job.');
                ex = ex.addCause(err);
                throw(ex);
            end
       end
    end
end

