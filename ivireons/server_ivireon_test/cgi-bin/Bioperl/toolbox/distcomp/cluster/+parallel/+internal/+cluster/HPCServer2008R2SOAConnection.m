classdef HPCServer2008R2SOAConnection < parallel.internal.cluster.AbstractHPCServerSOAConnection
    %HPCServer2008R2SOAConnection Class for connections to HPC Server 2008 R2 SOA API
    %   Class for interfacing to Microsoft.Hpc.Scheduler.DurableSession using
    %   MATLAB Interface to .NET Framework

    %  Copyright 2010 The MathWorks, Inc.

    %  $Revision: 1.1.6.3.2.2 $  $Date: 2010/07/23 15:35:46 $

    properties (Constant, GetAccess = private)
        HPC_SERVER_2008_R2_API_VERSION = 3;
        HPC_SERVER_2008_R2_NUMBER_OF_SOA_JOBS = 1;
        FoundV3Libraries = parallel.internal.cluster.HPCServer2008R2SOAConnection.loadAndCheckV3Libraries();
    end
    
    methods (Static) % AbstractHPCServerSOAConnection Abstract, static method implementation
        %---------------------------------------------------------------
        % isClientCompatible
        %---------------------------------------------------------------
        function isCompatible = isClientCompatible(schedulerVersion)
            % The HPC Server 2008 R2 API can be used to submit to either 
            % HPC Server 2008 R2 schedulers or HPC Server 2008 SP1 schedulers.
            % i.e. v3 API can be used with v2sp1 or v3 schedulers

            % TODO - no idea how to check for v2sp1 in beta1, so just
            % do v3 - v3 support for now.  
            import parallel.internal.cluster.HPCServer2008R2SOAConnection;
            isCompatible = ...
                (schedulerVersion == HPCServer2008R2SOAConnection.getRequiredMicrosoftAPIVersion()) && ...
                HPCServer2008R2SOAConnection.foundRequiredLibraries();
        end
    end

    methods (Static, Access = protected) % AbstractHPCServerSOAConnection Abstract, static, protected method implementation
        %---------------------------------------------------------------
        % getRequiredMicrosoftAPIVersion
        %---------------------------------------------------------------
        % The version of the Microsoft SOA API that is required
        function version = getRequiredMicrosoftAPIVersion
            version = parallel.internal.cluster.HPCServer2008R2SOAConnection.HPC_SERVER_2008_R2_API_VERSION;
        end

        %---------------------------------------------------------------
        % getExpectedNumberOfSOAJobs
        %---------------------------------------------------------------
        function numJobs = getExpectedNumberOfSOAJobs
            numJobs = parallel.internal.cluster.HPCServer2008R2SOAConnection.HPC_SERVER_2008_R2_NUMBER_OF_SOA_JOBS;
        end
    end

    methods (Static, Access = protected) % overrides of AbstractHPCServerSOAConnection, static, protected methods
        %---------------------------------------------------------------
        % foundRequiredLibraries
        %---------------------------------------------------------------
        function allFound = foundRequiredLibraries
            % We need to check explicitly for v3 of Microsoft.Hpc.Scheduler.Session.dll
            % because we use classes that are only in the v3 version.
            import parallel.internal.cluster.*;
            % NB calling base class implementations using @ requires full
            % package name for the base class
            allFound = foundRequiredLibraries@parallel.internal.cluster.AbstractHPCServerSOAConnection && ...
                HPCServer2008R2SOAConnection.FoundV3Libraries;
        end
    end

    methods (Static, Access = private) % Methods to support Constant properties.
        % Methods in this section should NEVER be called directly - use the constant properties instead.

        %---------------------------------------------------------------
        % loadAndCheckV3Libraries
        %---------------------------------------------------------------
        % NB This will only get called once by the constant FoundV3Libraries
        % property.  FoundV3Libraries will "persist" until 
        % "clear classes" is called.
        function success = loadAndCheckV3Libraries
            import parallel.internal.cluster.*
            success = false;
            if ~HPCServer2008R2SOAConnection.checkIfSessionLibraryIsV3()
                return;
            end
            
            if ~HPCServer2008R2SOAConnection.addMdcsServiceProxyAssembly()
                return;
            end
            
            success = true;
        end
        
        %---------------------------------------------------------------
        % addMdcsServiceProxyAssembly
        %---------------------------------------------------------------
        % NB This will only get called once by loadV3Libraries()
        % through the FoundV3Libraries property.  FoundV3Libraries will "persist" until 
        % "clear classes" is called.
        function assemblyIsAdded = addMdcsServiceProxyAssembly
            % Add the assembly for the SOA client - this may fail if the .NET security
            % policy is not up correctly.
            assemblyFilename = 'MdcsServiceProxy.dll';
            assemblyFullFilename = fullfile(toolboxdir('distcomp'), 'bin', dct_arch(), assemblyFilename);
            try
                NET.addAssembly(assemblyFullFilename);
                assemblyIsAdded = true;
            catch err 
                assemblyIsAdded = false;
                dctSchedulerMessage(5, 'Failed to load %s.\nReason:%s\n%s', assemblyFullFilename, err.getReport(), ...
                    parallel.internal.cluster.HPCServer2008SOAConnection.getNetworkInstallWarningMessage());
            end
        end
        
        %---------------------------------------------------------------
        % checkIfSessionLibraryIsV3
        %---------------------------------------------------------------
        % NB This will only get called once by loadV3Libraries()
        % through the FoundV3Libraries property.  FoundV3Libraries will "persist" until 
        % "clear classes" is called.
        function isV3 = checkIfSessionLibraryIsV3
            % TODO - at some point in the future, we'll probably be able to make
            % use of the Microsoft.Hpc.Scheduler.Session.ClientVersion property which
            % is new in the v3 API.  However, since we might load either a V2 or V3 
            % library when we get to here, we have to do a nasty hack to determine
            % the version of the client utilities.
            %
            % Note that for V3, the .NET assemblies are still labelled with version 
            % 2.0.0.0, so we cannot simply use the version number of the assembly.
            % Instead, we need to test for the presence of the DurableSession class
            % which is available in V3 and not in V2.
            import parallel.internal.cluster.*;
            isV3 = false;
            v3ClassName = 'Microsoft.Hpc.Scheduler.Session.DurableSession';
            try
                asm = NET.addAssembly(AbstractHPCServerSOAConnection.MicrosoftSessionAssembly);
                if ~any(strcmp(asm.Classes, v3ClassName))
                    return;
                end
            catch err %#ok<NASGU>
                return;
            end
            
            isV3 = true;
        end

    end

    methods (Static, Access = private)
        %---------------------------------------------------------------
        % closeAndDisposeSession
        %---------------------------------------------------------------
        function closeAndDisposeSession(session)
            try
                % cancel the job on the scheduler by closing and disposing of the session
                session.Close();
            catch err
                warning('distcomp:HPCServer2008R2SOAConnection:FailedToCloseSession', ...
                    'Failed to close session.  Reason:\n%s', err.getReport);
            end
            % NB Dispose will never throw exceptions
            session.Dispose();
        end
    end
    
    methods % constructors
        %---------------------------------------------------------------
        % constructor
        %---------------------------------------------------------------
        function obj = HPCServer2008R2SOAConnection(schedulerConnection, schedulerHostname)
            obj = obj@parallel.internal.cluster.AbstractHPCServerSOAConnection(schedulerConnection, schedulerHostname);
            % Nothing extra to do here for V3.
            % Ensure that we tell HPC Server that MATLAB is not a console
            % application so that the password prompt appears in the
            % correct place
            isConsoleApplication = false;
            parentWindow = 0;
            Microsoft.Hpc.Scheduler.Session.SessionBase.SetInterfaceMode(isConsoleApplication, ...
                    System.IntPtr(parentWindow));

        end
    end
    
    methods % AbstractHPCServerSOAConnection Abstract, public method implementation
        %---------------------------------------------------------------
        % closeJob
        %---------------------------------------------------------------
        function closeJob(obj, hpcServerJobID, ~)
            % If we got the wrong number of job IDs, then it is possible that the job
            % was not actually submitted using the v3 API.
            if numel(hpcServerJobID) ~= obj.HPC_SERVER_2008_R2_NUMBER_OF_SOA_JOBS
                return;
            end
            obj.attachAndCloseSession(hpcServerJobID);
        end
    end
    
    methods (Access = protected)  % AbstractHPCServerSOAConnection Abstract, protected method implementation
        %---------------------------------------------------------------
        % doJobSubmission
        %---------------------------------------------------------------
        function [schedulerJobID, jobName] = doJobSubmission(obj, jobID, jobLocation, ...
            taskIDs, taskLocations, taskLogLocations, jobTemplate, ...
            matlabExe, matlabArgs, environmentVariableDictionary, username, password)
            % import the namespace
            import Microsoft.Hpc.Scheduler.Session.*;
            import parallel.internal.cluster.HPCServer2008R2SOAConnection;
            
            session = obj.createSession(jobTemplate, username, password);
            try
                % Retrieve the job ID from the session and convert it to MATLAB types.
                schedulerJobID = double(session.Id);
                numJobIDs = length(schedulerJobID);
                % Make sure we got the correct number of jobs for this particular scheduler version
                if numJobIDs ~= HPCServer2008R2SOAConnection.getExpectedNumberOfSOAJobs
                    error('distcomp:HPCServer2008R2SOAConnection:IncorrectNumberOfJobIds', ...
                        'Obtained the incorrect number of Job IDs.  Expected %d, got %d', ...
                        HPCServer2008R2SOAConnection.getExpectedNumberOfSOAJobs, numJobIDs);
                end
                
                try
                    % Create the binding and the client
                    netTcpBinding = System.ServiceModel.NetTcpBinding(System.ServiceModel.SecurityMode.Transport);
                    client = NET.createGeneric('Microsoft.Hpc.Scheduler.Session.BrokerClient', ...
                        {HPCServer2008R2SOAConnection.ServiceType}, session, netTcpBinding);
                catch err
                    ex = MException('distcomp:HPCServer2008R2SOAConnection:FailedToCreateClient', ...
                        'Could not create the client for the SOA session.');
                    ex = ex.addCause(err);
                    throw(ex);
                end

                try
                     % Now do the requests
                     for ii = 1:numel(taskIDs)
                         request = Mathworks.MdcsServiceProxy.evaluateTaskRequest(jobID, ...
                             taskIDs(ii), matlabExe, matlabArgs, jobLocation, ...
                             taskLocations{ii}, taskLogLocations{ii}, environmentVariableDictionary);
                         NET.invokeGenericMethod(client, 'SendRequest', {'Mathworks.MdcsServiceProxy.evaluateTaskRequest'}, request, ii);
                     end
                     % Finish the requests
                     client.EndRequests();
                catch err
                    client.Dispose();
                    ex = MException('distcomp:HPCServer2008R2SOAConnection:FailedToSendRequests', ...
                        'Could not send the requests for the SOA job.');
                    ex = ex.addCause(err);
                    throw(ex);
                end
            catch err
                HPCServer2008R2SOAConnection.closeAndDisposeSession(session);
                rethrow(err);
            end

            % Dispose of the session and client.  NB do not close the session here
            % otherwise the job will be cancelled.  .NET types do not throw exceptions
            % from their Dispose functions.
            session.Dispose();
            client.Dispose();
            % Job name is always empty for R2 - we don't care what the job's name is.
            jobName = '';
        end
    end
    
    methods (Access = private)
        %---------------------------------------------------------------
        % attachAndCloseSession
        %---------------------------------------------------------------
        % Attach a session to the specified job and then close it to 
        % clean up.
        function attachAndCloseSession(obj, jobID)
            % import the namespace
            import Microsoft.Hpc.Scheduler.Session.*;
            
            try
                attachInfo = Microsoft.Hpc.Scheduler.Session.SessionAttachInfo(obj.SchedulerHostname, jobID);
                % Attach to the session
                session = DurableSession.AttachSession(attachInfo);
                obj.closeAndDisposeSession(session);
            catch err
                warning('distcomp:HPCServer2008R2SOAConnection:FailedToAttachSession', ...
                    'Failed to attach to the SOA session.  Job %d will not be closed correctly.  Reason: \n%s', ...
                    jobID, err.message);
            end
        end
        
        %---------------------------------------------------------------
        % createSession
        %---------------------------------------------------------------
        function session = createSession(obj, jobTemplate, username, password)
            try
                startInfo = Microsoft.Hpc.Scheduler.Session.SessionStartInfo(obj.SchedulerHostname, obj.ServiceName);
                % Set the resource unit type to core
                % To do this in MATLAB, we have to do it in a rather
                % convoluted way.  You cannot simply use the JobUnitType enum.  
                % The set ResourceUnitType method needs to be given a
                % System.Nullable<Microsoft.Hpc.Scheduler.Properties.JobUnitType>
                % which means that we must use NET.createGeneric
                jobUnitCore = NET.createGeneric('System.Nullable', ...
                    {'Microsoft.Hpc.Scheduler.Properties.JobUnitType'}, ...
                    Microsoft.Hpc.Scheduler.Properties.JobUnitType.Core);
                startInfo.ResourceUnitType = jobUnitCore;
                % Never set the min/max units - this is deferred to the job template
                if ~isempty(jobTemplate)
                    startInfo.JobTemplate = jobTemplate;
                end

                startInfo.Username = username;
                startInfo.Password = password;
            catch err
                ex = MException('distcomp:HPCServer2008R2SOAConnection:FailedToCreateSessionStartInfo', ...
                    'Could not create SOA session start info.');
                ex = ex.addCause(err);
                throw(ex);
            end
            
            try
                % Create the session
                session = Microsoft.Hpc.Scheduler.Session.DurableSession.CreateSession(startInfo);
            catch err
                ex = MException('distcomp:HPCServer2008R2SOAConnection:FailedToCreateSession', ...
                    'Could not create SOA session.');
                ex = ex.addCause(err);
                throw(ex);
            end
        end
    end
    
end