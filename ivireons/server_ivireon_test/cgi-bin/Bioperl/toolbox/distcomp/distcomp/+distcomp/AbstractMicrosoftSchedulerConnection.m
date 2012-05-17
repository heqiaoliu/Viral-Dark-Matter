classdef AbstractMicrosoftSchedulerConnection < handle
    %AbstractMicrosoftSchedulerConnection Abstract base class for connections to Microsoft scheduler APIs
    %   Abstract base class for connections to Microsoft scheduler using the Microsoft APIs.

    %  Copyright 2009-2010 The MathWorks, Inc.

    %  $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:14:31 $

    properties
        % The file from which we should start all job creation (except for SOA jobs)
        JobDescriptionFile = '';
    end
    
    properties (Dependent)
        % The maximum number of workers that we should use for each job.  
        % This is equivalent to the ClusterSize property in distcomp.ccsscheduler
        % and is used only for CCS v1 distributed jobs.  CCS v2 jobs will use the
        % values specified in the job template.  All parallel jobs will use the values
        % specified in the distcomp.simpleparalleljob.
        MaximumNumberOfWorkersPerJob;
    end
    
    
    properties (Dependent, SetAccess = protected)
        % The hostname of the scheduler to which we are connected
        SchedulerHostname;
        % The Major version of the scheduler to which we are connected.
        % This corresponds to the Major version of the scheduler 
        % CCS = 1, HPC Server 2008 = 2, HPC Server 2008 R2 = 3.
        SchedulerVersion;
        % Whether or not we are actually connected to a scheduler
        IsConnected;
        % The total number of cores available on the cluster to which we are 
        % connected.
        TotalNumberOfCores;
    end
    
    properties (Access = protected)
        % Flag to keep track of whether or not we have successfully connected
        % to the scheduler at least once.  Need to do this because calling
        % any functions on the Microsoft API without having first connected
        % can cause it to hang, even if you subsequently connect successfully.
        % Note that the only time that we will not be connected is just after
        % construction.  Once a connection (without any errors) has been made,
        % we can guarantee we will be connected to the correct scheduler.
        HaveSuccessfullyConnectedOnce = false;
    end
    
    properties (Constant, GetAccess = protected)
        % Used when submitting a job.  The client (i.e. MATLAB) is not a console application.
        IsConsoleApplication = false;
        % Used when submitting a job.  The handle to use as the parent window
        % for the credentials dialog. Setting to 0 means HWND_DESKTOP is
        % used as the parent.
        ParentWindow = 0;
        NotConnectedErrorID = 'distcomp:MicrosoftSchedulerConnection:NotConnectedToAScheduler';
        % Tell the scheduler that we don't want exclusive access to the nodes.  In other words,
        % other applications can run on the allocated nodes whilst this job is running.
        DoNotUseResourcesExclusively = false;
    end
    
    properties (Access = private)
        % Private scheduler hostname to support dependent SchedulerHostname property
        PrivateSchedulerHostname = '';
        % Private scheduler version to support dependent SchedulerVersion property
        PrivateSchedulerVersion;
        % Private max number of workers per job to support dependent 
        % MaximumNumberOfWorkersPerJob property
        % Default to inf until we are actually connected.
        PrivateMaximumNumberOfWorkerPerJob = inf;
    end
    
    methods
        %---------------------------------------------------------------
        % set.JobDescriptionFile
        %---------------------------------------------------------------
        function set.JobDescriptionFile(obj, xmlFilename)
            % If empty, just set it
            if isempty(xmlFilename)
                obj.JobDescriptionFile = xmlFilename;
                return;
            end

            % xmlFilename is not empty, so check that the file actually exists
            if exist(xmlFilename, 'file') == 0
                error(sprintf('distcomp:MicrosoftSchedulerConnection:%s', ...
                    distcomp.MicrosoftSchedulerConnectionExceptionManager.InvalidJobDescriptionFileErrorID), ...
                    'Cannot set job description file to "%s" because the file cannot be found.', ...
                    xmlFilename);
            end
            
            % Make sure we get the full path to the xml file, if it is on the search path.  
            obj.JobDescriptionFile = which(xmlFilename);
            % If the job description file is empty at this point, then we couldn't
            % locate via "which".  This is probably because the file is not on the search
            % path and an absolute or relative path to the file was supplied.
            if isempty(obj.JobDescriptionFile)
                f = java.io.File(xmlFilename);
                if f.isAbsolute
                    obj.JobDescriptionFile = xmlFilename;
                else
                    fullFilename = java.io.File(pwd, xmlFilename);
                    obj.JobDescriptionFile = char(fullFilename.getCanonicalFile);
                end
            end
        end
        
        %---------------------------------------------------------------
        % set.MaximumNumberOfWorkersPerJob
        %---------------------------------------------------------------
        function set.MaximumNumberOfWorkersPerJob(obj, maxWorkers)
            % Check that the maxWorkers value does not exceed the total
            % number of cores in the cluster
            if maxWorkers > obj.TotalNumberOfCores || maxWorkers < 1
                error(sprintf('distcomp:MicrosoftSchedulerConnection:%s', ...
                    distcomp.MicrosoftSchedulerConnectionExceptionManager.InvalidNumberOfWorkersErrorID), ...
                    'The %s must be between 1 and %d (total number of cores in the cluster)', ...
                    distcomp.MicrosoftSchedulerConnectionExceptionManager.InvalidNumberOfWorkersPhrase, ...
                    obj.TotalNumberOfCores);
            end
            obj.PrivateMaximumNumberOfWorkerPerJob = maxWorkers;
        end
        
        %---------------------------------------------------------------
        % get.MaximumNumberOfWorkersPerJob
        %---------------------------------------------------------------
        function maxWorkers = get.MaximumNumberOfWorkersPerJob(obj)
            maxWorkers = obj.PrivateMaximumNumberOfWorkerPerJob;
        end
        
        %---------------------------------------------------------------
        % set.SchedulerHostname
        %---------------------------------------------------------------
        % SetAccess = protected on SchedulerHostname property, so this
        % method should only be called by subclasses.
        function set.SchedulerHostname(obj, hostname)
            obj.PrivateSchedulerHostname = hostname;
        end

        %---------------------------------------------------------------
        % get.SchedulerHostname
        %---------------------------------------------------------------
        function hostname = get.SchedulerHostname(obj)
            if isempty(obj.PrivateSchedulerHostname)
	            obj.errorIfNotConnected;
                % Shouldn't get in here since PrivateSchedulerHostname is set
                % when connect() is called and if we aren't actually connected
                % to a scheduler, an error will already have been thrown.
                % Defer to each connection's implementation of getHostnameFromScheduler
                obj.PrivateSchedulerHostname = obj.getHostnameFromScheduler;
            end
            hostname = obj.PrivateSchedulerHostname;
        end

        %---------------------------------------------------------------
        % set.SchedulerVersion
        %---------------------------------------------------------------
        % SetAccess = protected on SchedulerVersion property, so this
        % method should only be called by subclasses.
        function set.SchedulerVersion(obj, version)
            obj.PrivateSchedulerVersion = version;
        end

        %---------------------------------------------------------------
        % get.SchedulerVersion
        %---------------------------------------------------------------
        function version = get.SchedulerVersion(obj)
            if isempty(obj.PrivateSchedulerVersion)
	            obj.errorIfNotConnected;
                % Shouldn't get in here since SchedulerVersion is set
                % when connect() is called and if we aren't actually connected
                % to a scheduler, an error will already have been thrown.
                % Defer to each connection's implementation of getVersionFromScheduler
                obj.PrivateSchedulerVersion = obj.getVersionFromScheduler;
            end
            version = obj.PrivateSchedulerVersion;
        end
        
        %---------------------------------------------------------------
        % get.IsConnected
        %---------------------------------------------------------------
        % Are we connected to any scheduler at all?
        function isConnected = get.IsConnected(obj)
            % Note: If calls to Connect in the Microsoft API cause an error, then
            % we remain connected to the previously connected scheduler (should
            % one exist).  Therefore, once we have connected successfully, we
            % know we will stay connected to something until destruction.
            isConnected = obj.HaveSuccessfullyConnectedOnce;
        end
        
        %---------------------------------------------------------------
        % isConnectedToScheduler
        %---------------------------------------------------------------
        % Are we connected to a particular scheduler?
        function isConnected = isConnectedToScheduler(obj, schedulerHostname)
            try
                isConnected = obj.IsConnected && strcmpi(schedulerHostname, obj.SchedulerHostname);
            catch err %#ok<NASGU>
                isConnected = false;
            end
        end
        
        %---------------------------------------------------------------
        % get.TotalNumberOfCores
        %---------------------------------------------------------------
        function numCores = get.TotalNumberOfCores(obj)
            obj.errorIfNotConnected;
            % Defer to each connection's implementation of getTotalCores
            numCores = obj.getTotalCores;
        end
        
        %---------------------------------------------------------------
        % cancelJob
        %---------------------------------------------------------------
        function cancelJob(obj, jobSchedulerData)
            obj.errorIfNotConnected;
            try
                % Cancel both jobs on the scheduler
                obj.cancelJobsByID([jobSchedulerData.SchedulerJobID; jobSchedulerData.SchedulerAdditionalJobID]);
            catch err
                ex = MException('distcomp:MicrosoftSchedulerConnection:FailedToCancelJob', ...
                    'Failed to cancel job on scheduler.');
                ex = ex.addCause(err);
                throw(ex);
            end
        end
    end
    
    methods (Abstract, Static)
        % The version of the API that is used to connect to the scheduler
        % Note that values for this need to be consistent with the
        % distcomp.microsoftclusterversion enum
        version = getAPIVersion;
        isCompatible = testClientCompatibilityWithMicrosoftAPI;
    end
    
    methods (Abstract)
        connect(obj, schedulerHostname);
        
        [schedulerJobIDs, schedulerTaskIDs, schedulerJobName] = submitJob(obj, job, matlabExe, matlabArgs, ...
            jobEnvironmentVariables, taskLocationEnvironmentVariableName, ...
            jobLocation, logLocationTemplate, logTaskIDToken, ...
            username, password);
        
        [schedulerJobIDs, schedulerTaskIDs] = submitParallelJob(obj, job, taskCommandToRun, ...
            jobEnvironmentVariables, logLocation, ...
            username, password);
        
        cancelTaskByID(obj, jobID, taskID);
        state = getJobStateByID(obj, jobID);
        jobDetails = getSchedulerDetailsForFailedJob(obj, jobID, taskID);
    end
    
    methods (Access = protected)
        %---------------------------------------------------------------
        % errorIfNotConnected
        %---------------------------------------------------------------
        function errorIfNotConnected(obj)
            if ~obj.IsConnected
                error(obj.NotConnectedErrorID, 'Not connected to a Microsoft scheduler.')
            end
        end
    end
    
    methods (Abstract, Access = protected)
        hostname = getHostnameFromScheduler(obj);
        version = getVersionFromScheduler(obj);
        totalCores = getTotalCores(obj);
        cancelJobsByID(obj, jobID);
    end
end

