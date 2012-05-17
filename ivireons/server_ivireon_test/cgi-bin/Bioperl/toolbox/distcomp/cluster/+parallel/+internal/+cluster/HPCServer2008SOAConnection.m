classdef HPCServer2008SOAConnection < parallel.internal.cluster.AbstractHPCServerSOAConnection
    %HPCServer2008SOAConnection Class for connections to HPC Server 2008 SOA API
    %   Class for interfacing to Microsoft.Hpc.Scheduler.Session and Mathworks.HpcServerSoaClient using
    %   MATLAB Interface to .NET Framework

    %  Copyright 2010 The MathWorks, Inc.

    %  $Revision: 1.1.6.2 $  $Date: 2010/05/10 17:03:53 $

    properties (Constant, GetAccess = private)
        HPC_SERVER_2008_API_VERSION = 2;
        HPC_SERVER_2008_NUMBER_OF_SOA_JOBS = 2;
        FoundV2Libraries = parallel.internal.cluster.HPCServer2008SOAConnection.loadAndCheckV2Libraries();
    end
    
    properties (Access = private)
        SOAClient;
    end

    methods (Static) % AbstractHPCServerSOAConnection Abstract, static method implementation
        %---------------------------------------------------------------
        % isClientCompatible
        %---------------------------------------------------------------
        function isCompatible = isClientCompatible(schedulerVersion)
            % The HPC Server 2008 API can only be used to HPC Server 2008 schedulers
            % i.e. v2 API can only be used with v2 schedulers.
            import parallel.internal.cluster.HPCServer2008SOAConnection;
            isCompatible = ...
                (schedulerVersion == HPCServer2008SOAConnection.getRequiredMicrosoftAPIVersion()) && ...
                HPCServer2008SOAConnection.foundRequiredLibraries();
        end
    end

    methods (Static, Access = protected) % AbstractHPCServerSOAConnection Abstract, static, protected method implementation
        %---------------------------------------------------------------
        % getRequiredMicrosoftAPIVersion
        %---------------------------------------------------------------
        % The version of the Microsoft SOA API that is required
        function version = getRequiredMicrosoftAPIVersion
            version = parallel.internal.cluster.HPCServer2008SOAConnection.HPC_SERVER_2008_API_VERSION;
        end

        %---------------------------------------------------------------
        % getExpectedNumberOfSOAJobs
        %---------------------------------------------------------------
        function numJobs = getExpectedNumberOfSOAJobs
            numJobs = parallel.internal.cluster.HPCServer2008SOAConnection.HPC_SERVER_2008_NUMBER_OF_SOA_JOBS;
        end
    end

    methods (Static, Access = protected) % overrides of AbstractHPCServerSOAConnection, static, protected methods
        %---------------------------------------------------------------
        % foundRequiredLibraries
        %---------------------------------------------------------------
        function allFound = foundRequiredLibraries
            % We don't explicitly need to check that Microsoft.Hpc.Scheduler.Session.dll is v2
            % since higher versions of the dll will still support the v2 API.
            % We just need to check that we can load and create Mathworks.HpcServerSoaClient
            import parallel.internal.cluster.*;
            % NB calling base class implementations using @ requires full
            % package name for the base class
            allFound = foundRequiredLibraries@parallel.internal.cluster.AbstractHPCServerSOAConnection && ...
                HPCServer2008SOAConnection.FoundV2Libraries;
        end
    end
    
    methods (Static, Access = private) % Methods to support Constant properties.
        % Methods in this section should NEVER be called directly - use the constant properties instead.

        %---------------------------------------------------------------
        % loadAndCheckV2Libraries
        %---------------------------------------------------------------
        % NB This will only get called once by the constant FoundV2Libraries
        % property.  FoundV2Libraries will "persist" until 
        % "clear classes" is called.
        function success = loadAndCheckV2Libraries
            % Add the assembly for the SOA client - this may fail if the .NET security
            % policy is not up correctly.
            assemblyFilename = 'HpcServerSoaClient.dll';
            assemblyFullFilename = fullfile(toolboxdir('distcomp'), 'bin', dct_arch(), assemblyFilename);
            
            try
                NET.addAssembly(assemblyFullFilename);
                soaClient = Mathworks.HpcServerSoaClient.ComSoaClientManager();
                % make sure we dispose of the SOA connection to free up resources
                soaClient.Dispose();
                success = true;
            catch err
                success = false;
                dctSchedulerMessage(5, 'Failed to load %s.\nReason:%s\n%s', assemblyFullFilename, err.getReport(), ...
                    parallel.internal.cluster.HPCServer2008SOAConnection.getNetworkInstallWarningMessage());
            end
        end
    end
    
    methods % constructors
        %---------------------------------------------------------------
        % constructor
        %---------------------------------------------------------------
        function obj = HPCServer2008SOAConnection(schedulerConnection, schedulerHostname)
            obj = obj@parallel.internal.cluster.AbstractHPCServerSOAConnection(schedulerConnection, schedulerHostname);
            
            % Now create the ComSoaClientManager.  We already know that it is possible
            % to create an instance of it (this was checked in the base class constructor).
            try
                obj.SOAClient = Mathworks.HpcServerSoaClient.ComSoaClientManager(...
                    schedulerHostname, schedulerConnection);
            catch err 
                % Really shouldn't get in here.
                ex = MException('distcomp:HPCServerSchedulerConnection:UnableToLaunchSOAClient', ...
                    'Failed to create SOA client.  You cannot submit SOA jobs.');
                ex = ex.addCause(err);
                throw(ex)
            end
        end
        
        %---------------------------------------------------------------
        % Delete
        %---------------------------------------------------------------
        function delete(obj)
            % Dispose of the SOA client
            % Note that .NET Dispose functions should never throw exceptions
            % Note: obj.SOAClient should never be empty.
            % Checking for IDisposable is just a sanity check.  obj.SOAClient 
            % should ALWAYS be disposable
            if isa(obj.SOAClient, 'System.IDisposable') 
                obj.SOAClient.Dispose();
            end
        end
    end
    
       
    methods % AbstractHPCServerSOAConnection Abstract, public method implementation
        %---------------------------------------------------------------
        % closeJob
        %---------------------------------------------------------------
        function closeJob(obj, ~, jobName)
            % If we got an empty job name then it is possible that the job
            % was not actually submitted using the v2 API.
            if isempty(jobName)
                return;
            end
            obj.closeSOAClient(jobName);
        end
    end
    
    methods (Access = protected)  % AbstractHPCServerSOAConnection Abstract, protected method implementation
        %---------------------------------------------------------------
        % doJobSubmission
        %---------------------------------------------------------------
        function [jobIDs, jobName] = doJobSubmission(obj, jobID, jobLocation, ...
            taskIDs, taskLocations, taskLogLocations, jobTemplate, ...
            matlabExe, matlabArgs, environmentVariableDictionary, username, password)
            
            [soaJobAttributes, matlabJobAttributes, taskAttributes] = obj.generateSOAInputs(...
                jobID, jobLocation, taskIDs, taskLocations, taskLogLocations, ...
                jobTemplate, matlabExe, matlabArgs, environmentVariableDictionary, username, password);
            try
                % Tell the SOA client to evaluate the tasks.  This call will return (almost) immediately.
                jobIDArray = obj.SOAClient.submitSoaJob(soaJobAttributes, matlabJobAttributes, taskAttributes);
                % Convert the .NET array into a MATLAB array
                jobIDs = double(jobIDArray);
                numJobIDs = length(jobIDs);
                % Make sure we got the correct number of jobs for this particular scheduler version
                if numJobIDs ~= obj.getExpectedNumberOfSOAJobs
                    error('distcomp:HPCServer2008SOAConnection:IncorrectNumberOfJobIds', ...
                        'Obtained the incorrect number of Job IDs.  Expected %d, got %d', ...
                        obj.getExpectedNumberOfSOAJobs, numJobIDs);
                end
            catch err
                % cancel the job on the scheduler by closing the SOA client
                obj.closeSOAClient(soaJobAttributes.serviceJobName);
                % and rethrow the error.
                rethrow(err);
            end
            % Get the job name out of the soaJobAttributes
            jobName = char(soaJobAttributes.serviceJobName);
        end
    end
    
    methods (Access = private)
        %---------------------------------------------------------------
        % closeSOAClient
        %---------------------------------------------------------------
        function closeSOAClient(obj, jobName)
            try
                % Close the SOA client
                obj.SOAClient.closeSoaClient(jobName);
            catch err
                warning('distcomp:HPCServer2008SOAConnection:FailedToCloseSOAClient', ...
                    'Failed to close SOA client for job %s.  Reason: \n%s', uniqueJobName, err.message);
            end
        end
        
        %---------------------------------------------------------------
        % generateSOAInputs
        %---------------------------------------------------------------
        function [soaJobAttributes, matlabJobAttributes, taskAttributes] = generateSOAInputs(...
                obj, jobID, jobLocation, taskIDs, taskLocations, taskLogLocations, ...
                jobTemplate, matlabExe, matlabArgs, jobEnvironmentVariables, username, password)
            numTasks = numel(taskIDs);
            
            % set the job timeout to maximum value.  (Job timeout does not exist for simplejob)
            jobTimeout = int32(inf);
            try
                % Create the SOA Job, matlab job and task attributes for use with the
                % SOA connection
                uniqueJobName = Mathworks.HpcServerSoaClient.ComSoaClientManager.generateUniqueJobName(jobID);
                soaJobAttributes = Mathworks.HpcServerSoaClient.SoaJobAttributes(obj.SchedulerHostname, username, password, ...
                    obj.ServiceName, uniqueJobName, jobTemplate);
                matlabJobAttributes = Mathworks.HpcServerSoaClient.MatlabJobAttributes(jobID, matlabExe, matlabArgs, ...
                    jobLocation, jobEnvironmentVariables, jobTimeout);
                % Create an array of TaskAttributes[]
                taskAttributes = NET.createArray('Mathworks.HpcServerSoaClient.TaskAttributes', numTasks);
                for ii = 1:numTasks
                    taskAttrib = Mathworks.HpcServerSoaClient.TaskAttributes(taskIDs(ii), taskLocations{ii}, taskLogLocations{ii});
                    % NB zero-based indexing for .NET types
                    taskAttributes.Set(ii-1, taskAttrib);
                end
            catch err
                % and throw an error.
                ex = MException('distcomp:HPCServer2008SOAConnection:FailedToGenerateSOAInputs', ...
                    'Error occurred when generating the SOA job inputs.');
                ex = ex.addCause(err);
                throw(ex);
            end
        end
    end
end