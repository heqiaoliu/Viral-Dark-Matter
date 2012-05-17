classdef CCSSchedulerConnection < distcomp.AbstractMicrosoftSchedulerConnection
    %CCSSchedulerConnection Class for connections to Microsoft CCS scheduler APIs
    %   Class for interfacing to ccpapi.dll using MATLAB COM Client Support.

    %  Copyright 2009-2010 The MathWorks, Inc.

    %  $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:14:32 $

    properties (Constant, GetAccess = protected)
        CanCreateMicrosoftCompluteCluster = distcomp.CCSSchedulerConnection.testComputeClusterCreation;
    end
    
    properties (Access = private)
        % The actual connection to the CCS API.  This is handle to COM object
        % Microsoft.ComputeCluster.Cluster
        ComputeClusterConnection;
    end
    
    methods (Static, Access = protected) % Methods to support Constant, protected properties.
        % Methods in this section should NEVER be called directly - use the constant properties instead.
        
        %---------------------------------------------------------------
        % testComputeClusterCreation
        %---------------------------------------------------------------
        % NB This will only get called once by the constant CanCreateMicrosoftCompluteCluster
        % property.  distcomp.CanCreateMicrosoftCompluteCluster will "persist" until
        % "clear classes" is called.
        function canCreate = testComputeClusterCreation
            % See if we can create a .NET connection to the scheduler
            try
                % Let's test that we are able to create an activex link to the scheduler
                testObj = actxserver('Microsoft.ComputeCluster.Cluster'); %#ok<NASGU>
                canCreate = true;
            catch err %#ok<NASGU>
                canCreate = false;
            end
        end
    end

    methods (Static)% AbstractMicrosoftSchedulerConnection Abstract, static method implementation
        %---------------------------------------------------------------
        % getAPIVersion
        %---------------------------------------------------------------
        function version = getAPIVersion
            % NB This needs to be a string that matches the value
            % of distcomp.microsoftclusterversion
            version = 'CCS';
        end

        %---------------------------------------------------------------
        % testClientCompatibilityWithMicrosoftAPI
        %---------------------------------------------------------------
        % Test whether or not Microsoft.ComputeCluster.Cluster can be 
        % constructed.
        function isCompatible = testClientCompatibilityWithMicrosoftAPI
            isCompatible = distcomp.CCSSchedulerConnection.CanCreateMicrosoftCompluteCluster;
        end
    end


    methods
        %---------------------------------------------------------------
        % CCSSchedulerConnection constructor
        %---------------------------------------------------------------
        function obj = CCSSchedulerConnection
            try
                % Let's test that we are able to create an activex link to the scheduler
                obj.ComputeClusterConnection = actxserver('Microsoft.ComputeCluster.Cluster');
            catch err
                ex = MException(sprintf('distcomp:CCSSchedulerConnection:%s', ...
                    distcomp.MicrosoftSchedulerConnectionExceptionManager.UnableToContactServiceErrorID),...
                    'It appears that the Microsoft Compute Cluster Server is not installed on this machine');
                ex = ex.addCause(err);
                throw(ex);
            end
        end
    end
    
    methods % AbstractMicrosoftSchedulerConnection Abstract public method implementation
        
        %---------------------------------------------------------------
        % connect
        %---------------------------------------------------------------
        % Connect to the specified scheduler hostname.  Note that v1 server connections
        % can connect to both v1 (CCS) and v2 (HPCS) schedulers.
        function connect(obj, schedulerHostname)
            if obj.isConnectedToScheduler(schedulerHostname)
                % Already connected to that scheduler
                return;
            end
            
            try
                obj.ComputeClusterConnection.Connect(schedulerHostname);
                % NB must set the hostname and version when we successfully connect
                obj.SchedulerVersion = obj.getVersionFromScheduler;
                obj.SchedulerHostname = schedulerHostname;
                % Indicate that we've connected at least once
                obj.HaveSuccessfullyConnectedOnce = true;
            catch err
                % Throw an error
                ex = MException('distcomp:CCSSchedulerConnection:UnableToConnect', ...
                    'Unable to contact a CCS scheduler on machine %s', schedulerHostname);
                ex = ex.addCause(err);
                throw(ex)
            end
            
            % Always set the Maxmimum number of workers to a sensible value when 
            % connecting to a new cluster
            obj.MaximumNumberOfWorkersPerJob = obj.TotalNumberOfCores;
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
                ~, logLocationTemplate, logTaskIDToken, ...
                username, password)
            obj.errorIfNotConnected;
            
            % Job Name is relevant only for SOA v2 jobs
            schedulerJobName = '';
            % We're sure the cluster connection is actually connected to a scheduler
            tasks = job.Tasks;
            numTasks = numel(tasks);
            matlabCommand = sprintf('"%s" %s', matlabExe,  matlabArgs);
            
            % Determine whether or not we should set min/max and isExclusive properties on ccsJob 
            % or if we should defer to the values already loaded from the XML
            try
                [minWorkersDefined, maxWorkersDefined, isExclusiveDefined] = obj.parseDescriptionFile;
            catch err
                % Something went wrong when parsing the XML file. (Unlikely to get in here
                % since if the XML file is incorrect, createJobOnScheduler would already have
                % errored.)
                % Assume that we need to override the properties.
                warning('distcomp:CCSSchedulerConnection:FailedToParseJobDescriptionFile', ...
                    'Failed to parse job description file.  Job Properties may be overwritten.\n\tReason: %s', err.message);
                minWorkersDefined = false;
                maxWorkersDefined = false;
                isExclusiveDefined = false;
            end

            % Create a new job
            ccsJob = obj.createJobOnScheduler();
            % Set minimum and maximum resource usage and IsExclusive as appropriate
            if ~maxWorkersDefined
                ccsJob.MaximumNumberOfProcessors = min(numTasks, obj.MaximumNumberOfWorkersPerJob);
            end
            if ~minWorkersDefined
                ccsJob.MinimumNumberOfProcessors = 1;
            end
            if ~isExclusiveDefined
                ccsJob.IsExclusive = obj.DoNotUseResourcesExclusively;
            end
            
            % For each task add the task to the job and set the environment variables
            % Need to store the ID of the task to reindex into the CCS tasks
            schedulerTaskIDs = zeros(numTasks, 1);
            for i = 1:numTasks
                % Create the task
                t = obj.ComputeClusterConnection.CreateTask();
                
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
                t.Stdout = logLocation;
                t.Stderr = logLocation;
                
                % Setting task to not exclusive ensures that multiple tasks from the same job 
                % can run on the same node.
                t.IsExclusive = obj.DoNotUseResourcesExclusively;
                t.CommandLine = matlabCommand;
                
                % Now add the task to the job
                ccsJob.AddTask(t);
                % NOTE - CCS doesn't actually know the ID of it's task at this point so
                % we will assume it grows monotonically from 1
                schedulerTaskIDs(i) = i;
            end
            
            % Now queue the job on the current controller to get a job id
            ccsJobID = obj.ComputeClusterConnection.AddJob(ccsJob);
            
            % Set the credentials for the job and submit the job
            obj.ComputeClusterConnection.SubmitJob(ccsJobID, username, password, ...
                obj.IsConsoleApplication, obj.ParentWindow);
            
            % Only one ccs job ID for v1 jobs.
            schedulerJobIDs = ccsJobID;
        end
        
        %---------------------------------------------------------------
        % submitParallelJob
        %---------------------------------------------------------------
        % NB Assumes that the job's tasks have already been duplicated and that the job has been
        % prepared for submission
        %
        % job                       distcomp.abstractjob
        % taskCommandToRun          the command to run by the task (i.e. mpiexec .......)
        % jobEnvironmentVariables   all the environment variables that are common for the distributed job
        % logLocation               the (full path to the) location to use for the task's log
        % username                  the username which will be used to launch the matlab processes
        % password                  the password associated with the username (an empty string will
        %                           cause the user to be prompted to enter a password).
        function [schedulerJobIDs, schedulerTaskIDs] = submitParallelJob(obj, job, taskCommandToRun, ...
                jobEnvironmentVariables, logLocation, ...
                username, password)
            obj.errorIfNotConnected;
            
            % Ensure we have enough cores on the cluster
            minProcessors = job.MinimumNumberOfWorkers;
            maxProcessors = job.MaximumNumberOfWorkers;
            totalCores = obj.TotalNumberOfCores;
            assert(totalCores >= minProcessors, 'distcomp:CCSSchedulerConnection:ResourceLimit', ...
                    'The job has requested %d workers. The CCS scheduler only has %d cores in the cluster', ...
                    minProcessors, totalCores);
            
            % Determine whether or not we should set isExclusive or 
            % if we should defer to the XML file values.  We aren't interested
            % in whether or not the XML file defines min/max processors, as we
            % will be using the values defined in the parallel job.
            try
                [~, ~, isExclusiveDefined] = obj.parseDescriptionFile;
            catch err
                % Something went wrong when parsing the XML file. (Unlikely to get in here
                % since if the XML file is incorrect, createJobOnScheduler would already have
                % errored.)
                % Assume that we need to override the properties.
                warning('distcomp:CCSSchedulerConnection:FailedToParseJobXML', ...
                    'Failed to parse job XML file.  Job Properties may be overwritten.\n\tReason: %s', err.message);
                isExclusiveDefined = false;
            end

            % Create a new job
            ccsJob = obj.createJobOnScheduler;
            % Always set the requested number of processors for parallel jobs, regardless
            % of whether these values may/may not be defined in the XML.
            ccsJob.MaximumNumberOfProcessors = maxProcessors;
            ccsJob.MinimumNumberOfProcessors = minProcessors;
            if ~isExclusiveDefined
                ccsJob.IsExclusive = obj.DoNotUseResourcesExclusively;
            end
            
            % All tasks will attach to task 1 on the scheduler
            tasks = job.Tasks;
            numTasks = numel(tasks);
            schedulerTaskIDs = ones(numTasks, 1);
            
            % Create the one parallel task
            t = obj.ComputeClusterConnection.CreateTask();
            % Set the requested number of processors
            t.MaximumNumberOfProcessors = maxProcessors;
            t.MinimumNumberOfProcessors = minProcessors;
            % Setting task to not exclusive ensures that multiple tasks from the same job 
            % can run on the same node.
            t.IsExclusive = obj.DoNotUseResourcesExclusively;
            
            % Now set the environment variables
            for k = 1:size(jobEnvironmentVariables, 1)
                t.SetEnvironmentVariable(jobEnvironmentVariables{k, 1}, jobEnvironmentVariables{k, 2});
            end
            
            if ~isempty(logLocation)
                % Redirect stdout and stderr to the log
                t.Stdout = logLocation;
                t.Stderr = logLocation;
            end
            
            t.CommandLine = taskCommandToRun;
            
            % Now add the task to the job
            ccsJob.AddTask(t);
            
            % Now queue the job on the current controller to get a job id
            ccsJobID = obj.ComputeClusterConnection.AddJob(ccsJob);
            
            % Set the credentials for the job and submit the job
            obj.ComputeClusterConnection.SubmitJob(ccsJobID, username, password, ...
                obj.IsConsoleApplication, obj.ParentWindow);
            
            % Only one ccs job ID for v1 jobs.
            schedulerJobIDs = ccsJobID;
        end
        
        %---------------------------------------------------------------
        % cancelTaskByID
        %---------------------------------------------------------------
        % Cancel the specified task in the specified job on CCS.  The jobID and taskID
        % are CCS's IDs.
        function cancelTaskByID(obj, jobID, taskID)
            obj.errorIfNotConnected;
            % Only cancel the task if the scheduler thinks it's not finished.
            % CCSAPI.dll will return an empty task if it doesn't actually exist.
            t = obj.ComputeClusterConnection.GetTask(jobID, taskID);
            if isempty(t)
                warning('distcomp:CCSSchedulerConnection:UnableToCancelTask', ...
                    'Unable to cancel task %d for job %d because the task does not exist on the scheduler.', ...
                    taskID, jobID);
                return;
            end
            
            if any(strcmp(t.status, ...
                    {'TaskStatus_NotSubmitted' 'TaskStatus_Queued' 'TaskStatus_Running'}));
                % And cancel the task
                cancellationMessage = '';
                obj.ComputeClusterConnection.CancelTask(jobID, taskID, cancellationMessage);
            end
        end
        
        %---------------------------------------------------------------
        % getJobStateByID
        %---------------------------------------------------------------
        % Get the state of the specified job.  The jobID is the CCS job ID.
        function state = getJobStateByID(obj, jobID)
            obj.errorIfNotConnected;

            % Ask CCS about this job
            j = obj.getJobByID(jobID);

            % Map CCS job status to Matlab job status
            switch j.status
                case {'JobStatus_NotSubmitted' 'JobStatus_Queued'}
                    state = 'queued';
                case 'JobStatus_Running'
                    state = 'running';
                case {'JobStatus_Finished' 'JobStatus_Cancelled'}
                    state = 'finished';
                case 'JobStatus_Failed'
                    state = 'failed';
                otherwise
                    % Shouldn't get here.
                    error('distcomp:CCSSchedulerConnection:getJobStateByID', ...
                        'CCS returned an unknown job status for job %d.', jobID);
            end
        end
        
        %---------------------------------------------------------------
        % getSchedulerDetailsForFailedJob
        %---------------------------------------------------------------
        % Get job details from CCS for the specified job and task IDs.
        % Returns a string for use in debug logs.  The jobID and taskID are
        % CCS's IDs. TaskID is optional
        function jobDetails = getSchedulerDetailsForFailedJob(obj, jobID, taskID)
            obj.errorIfNotConnected;
            
            if nargin < 2
                taskID = [];
            end

            % Start with the error message for the job
            try
                ccsJob = obj.getJobByID(jobID);
            catch err %#ok<NASGU>
                jobDetails = sprintf('Unable to retrieve job %d from the scheduler', jobID);
                return;
            end

            % We have a valid job, so find the job details
            cellout{1} = sprintf('Getting data for CCS JobID %d\n', jobID);
            cellout{2} = sprintf('Error Message : %s\n', ccsJob.ErrorMessage);
            
            % Then the details for the task, if specified
            if ~isempty(taskID)
                ccsTask = obj.ComputeClusterConnection.GetTask(jobID, taskID);
                if isempty(ccsTask)
                    cellout{3} = sprintf('Unable to retrieve task %d for job %d from the scheduler', taskID, jobID);
                else
                    cellout{3} = sprintf('Getting data for CCS JobID %d and TaskID %d\n', jobID, taskID);
                    cellout{4} = sprintf('CommandLine   : %s\n', ccsTask.CommandLine);
                    cellout{5} = sprintf('Stdout sent   : %s\n', ccsTask.Stdout);
                    cellout{6} = sprintf('Error Message : %s\n', ccsTask.ErrorMessage);
                end
            end
            jobDetails = sprintf('%s', cellout{:});
        end
    end

    methods (Access = protected) % AbstractMicrosoftSchedulerConnection Abstract protected method implementation
        %---------------------------------------------------------------
        % getHostnameFromScheduler
        %---------------------------------------------------------------
        % Get the scheduler hostname from the server connection.
        function hostname = getHostnameFromScheduler(obj)
            try
                hostname = obj.ComputeClusterConnection.Name;
            catch err
                ex = MException('distcomp:CCSSchedulerConnection:UnableToFindHeadNode', ...
                    'Failed to retrieve name from scheduler.');
                ex = ex.addCause(err);
                throw(ex);
            end
            
            % NB Microsoft.ComputeCluster.Cluster sets name to an empty string
            % when it is constructed.  Furthermore, attempting to connect to a
            % hostname = '' will generate an error.
            % Therefore, if the hostname is an empty string, then we know that
            % we're not actually connected to a scheduler
            if strcmp(hostname, '')
                error(obj.NotConnectedErrorID, 'Not connected to a CCS Scheduler.')
            end
        end
        
        %---------------------------------------------------------------
        % getVersionFromScheduler
        %---------------------------------------------------------------
        % Get the scheduler version from the server connection.
        % This is a bit of a hack for CCS because there is no way of 
        % querying the scheduler to find out which version it is, so
        % we just have to assume that if we are using the CCS api to 
        % connect to the scheduler, then it must be version 1.
        function version = getVersionFromScheduler(~)
            version = 1;
        end

        
        %---------------------------------------------------------------
        % getTotalCores
        %---------------------------------------------------------------
        % Gets the total number of cores in the cluster. 
        % Note that this value represents the actual number of cores in the cluster
        % and does not provide any information about how many cores actually belong
        % to compute nodes.
        function totalCores = getTotalCores(obj)
            totalCores = obj.ComputeClusterConnection.ClusterCounter.TotalNumberOfProcessors;
        end
        
        %---------------------------------------------------------------
        % cancelJobsByID
        %---------------------------------------------------------------
        % Cancel the specified job on CCS.  jobID is a vector of CCS job IDs.
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
                    % Only cancel the job if the scheduler thinks it's not finished
                    if any(strcmp(ccsJob.status, ...
                            {'JobStatus_NotSubmitted' 'JobStatus_Queued' 'JobStatus_Running'}));
                        % And cancel the job
                        cancellationMessage = '';
                        obj.ComputeClusterConnection.CancelJob(jobID, cancellationMessage);
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
    end

    methods (Access = protected)  
        %---------------------------------------------------------------
        % getJobByID
        %---------------------------------------------------------------
        function job = getJobByID(obj, jobID)
            % NB For V1, the returned job is empty if the job doesn't actually exist on the scheduler.
            % No error is thrown, so we need to thow our own error if the job couldn't be found (to 
            % ensure that the behaviour here is consistent with HPCServerSchedulerConnection).
            job = obj.ComputeClusterConnection.GetJob(jobID);
            if isempty(job)
                error('distcomp:CCSSchedulerConnection:UnableToRetrieveJob', ...
                    'Unable to retrieve job %d from the scheduler because it does not exist.', jobID);
            end
        end

        %---------------------------------------------------------------
        % createJob
        %---------------------------------------------------------------
        % Creates a ccs Job, applying the job XML Description file, if appropriate.
        function schedulerJob = createJobOnScheduler(obj)
            % If an XML file is defined, then create the job from the XML.
            
            if isempty(obj.JobDescriptionFile)
                % Create a new job
                schedulerJob = obj.ComputeClusterConnection.CreateJob();
                return;
            end
            
            try
                schedulerJob = obj.ComputeClusterConnection.CreateJobFromXmlFile(obj.JobDescriptionFile);
            catch err
                ex = MException(sprintf('distcomp:CCSSchedulerConnection:%s', ...
                    distcomp.MicrosoftSchedulerConnectionExceptionManager.FailedToCreateJobFromXMLErrorID), ...
                    'Failed to create job from xml file %s', obj.JobDescriptionFile);
                ex = ex.addCause(err);
                throw(ex);
            end
        end

        %---------------------------------------------------------------
        % parseDescriptionFile
        %---------------------------------------------------------------
        % Parses the JobDescriptionFile and determines if the attributes for 
        % min/max processors and IsExclusive are defined in the  file.  
        function [minWorkersDefined, maxWorkersDefined, isExclusiveDefined] = parseDescriptionFile(obj)
            if isempty(obj.JobDescriptionFile)
                minWorkersDefined = false;
                maxWorkersDefined = false;
                isExclusiveDefined = false;
                return;
            end
        
            xmlFileDOM = xmlread(obj.JobDescriptionFile);
            allJobNodes = xmlFileDOM.getElementsByTagName('Job');

            if allJobNodes.getLength ~= 1
                error('distcomp:CCSSchedulerConnection:DescriptionFileParseError', ...
                    'Job description file %s should contain only 1 job node.  Found %d job nodes.', ...
                    obj.JobDescriptionFile, alljobNodes.getLength);
            end
            
            jobNode = allJobNodes.item(0);
            minWorkersDefined = jobNode.hasAttribute('MinimumNumberOfProcessors');
            maxWorkersDefined = jobNode.hasAttribute('MaximumNumberOfProcessors');
            isExclusiveDefined = jobNode.hasAttribute('IsExclusive');
        end
    end

end

