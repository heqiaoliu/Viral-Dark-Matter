classdef AbstractHPCServerSOAConnection < handle
    %AbstractHPCServerSOAConnection Abstract base class for connections to HPC Server 2008 SOA APIs
    %   Abstract base class for SOA connections to Microsoft scheduler using the Microsoft APIs.

    %  Copyright 2010 The MathWorks, Inc.

    %  $Revision: 1.1.6.2 $  $Date: 2010/05/10 17:03:51 $
    
    properties (Constant, GetAccess = protected)
        ServiceType = 'Mathworks.MdcsServiceProxy.IMdcsService';
        ServiceName = parallel.internal.cluster.AbstractHPCServerSOAConnection.getServiceName;
        MicrosoftSessionAssembly = 'Microsoft.Hpc.Scheduler.Session';
        FoundMicrosoftHpcSchedulerSessionLibrary = parallel.internal.cluster.AbstractHPCServerSOAConnection.addMicrosoftHpcSchedulerSessionAssembly;
    end
    
    properties (Access = protected)
        % The Microsoft.Hpc.Scheduler.Scheduler connection that will be used to
        % talk to the HPC Server scheduler
        SchedulerConnection;
        % The hostname of the scheduler to which we are connected
        SchedulerHostname;
    end
    
    methods (Static, Access = private) % Methods to support Constant properties.
        % Methods in this section should NEVER be called directly - use the constant properties instead.
        
        %---------------------------------------------------------------
        % getServiceName
        %---------------------------------------------------------------
        % Get the name of the service that will actually run.  This corresponds to
        % the name of the file that is found in %CCP_HOME%\ServiceRegistration.
        function serviceName = getServiceName
            % The service name is based on the pctversion number.
            pctVersion = char(com.mathworks.toolbox.distcomp.util.Version.VERSION_STRING);
            serviceName = sprintf('MdcsServiceForPCT%s', pctVersion);
        end
        %---------------------------------------------------------------
        % addMicrosoftHpcSchedulerSessionAssembly
        %---------------------------------------------------------------
        % NB This will only get called once by the constant 
        % FoundMicrosoftHpcSchedulerSessionLibrary property.  
        % FoundMicrosoftHpcSchedulerSessionLibrary will "persist" until
        % "clear classes" is called.
        function assemblyIsAdded = addMicrosoftHpcSchedulerSessionAssembly
        
            assemblyName = parallel.internal.cluster.AbstractHPCServerSOAConnection.MicrosoftSessionAssembly;
            try
                NET.addAssembly(assemblyName);
                assemblyIsAdded = true;
            catch err 
                assemblyIsAdded = false;
                dctSchedulerMessage(5, 'Failed to load %s.\nReason:%s\n%s', assemblyName, err.getReport(), ...
                    parallel.internal.cluster.AbstractHPCServerSOAConnection.getNetworkInstallWarningMessage());
            end
        end
    end
    
    methods (Static, Access = protected)
        %---------------------------------------------------------------
        % foundRequiredLibraries
        %---------------------------------------------------------------
        function allFound = foundRequiredLibraries
            % Must be running on win64 in order to find the required libraries.
            allFound = strcmpi(dct_arch(), 'win64') && ...
                parallel.internal.cluster.AbstractHPCServerSOAConnection.FoundMicrosoftHpcSchedulerSessionLibrary;
        end
    end

    methods (Static, Access = protected)
        %---------------------------------------------------------------
        % getNetworkInstallWarningMessage
        %---------------------------------------------------------------
        % returns the message about network security for .NET assemblies if we
        % detect that we are running from a network install.
        function message = getNetworkInstallWarningMessage
            % If we are running from a network share then it is possible the security settings
            % are not set up correctly.
            % TODO - If running on a Network Share then try running the caspol code (addAssembliesToCaspol.bat)?
            if iIsNetworkInstall
                message = [...
                    'It is possible that the .NET configuration for this machine has not been modified to grant\n'...
                    'Full Trust to .NET assemblies located on a network share.\n\n'...
                    'Please see the Parallel Computing Toolbox and MATLAB Distributed Computing Server\n'...
                    'installation instructions or contact your system administrator for more details on \n' ...
                    'how to rectify this.'];
            else
                message = '';
            end
        end
    end
    
    methods (Abstract, Static) % Abstract, static methods
        isCompatible = isClientCompatible(schedulerVersion);
    end
    
    methods (Abstract, Static, Access = protected) %Abstract, static, protected methods
        % The version of the Microsoft SOA API that is required
        version = getRequiredMicrosoftAPIVersion;
        numJobs = getExpectedNumberOfSOAJobs;
    end
    
    methods
        %---------------------------------------------------------------
        % constructor
        %---------------------------------------------------------------
        function obj = AbstractHPCServerSOAConnection(schedulerConnection, schedulerHostname)
            import parallel.internal.cluster.*
            if ~AbstractHPCServerSOAConnection.foundRequiredLibraries
                error('distcomp:AbstractHPCServerSOAConnection:SOANotSupported', ...
                    'SOA Jobs cannot be submitted from this client machine because the required libraries could not be loaded.');
            end
            
            % Must have 2 input args
            error(nargchk(2, 2, nargin, 'struct'));
            % And schedulerConnection must be of type Microsoft.Hpc.Scheduler.Scheduler
            if ~isa(schedulerConnection, 'Microsoft.Hpc.Scheduler.Scheduler')
                error('distcomp:AbstractHPCServerSOAConnection:InvalidArgument', ...
                    'Scheduler connection must be of type Microsoft.Hpc.Scheduler.Scheduler');
            end
            
            % Check for version compatibility before going any further.
            schedulerVersion = double(schedulerConnection.GetServerVersion().Major);
            if ~obj.isClientCompatible(schedulerVersion)
                error('distcomp:AbstractHPCServerSOAConnection:IncorrectSchedulerVersion', ...
                    'Scheduler version %d is not compatible with current API version %d.', ...
                    schedulerVersion, obj.getRequiredMicrosoftAPIVersion());
            end

            % NB there is an assumption that the connection that we receive is already
            % connected to the correct scheduler.  Unfortunately, Microsoft's API does
            % not give us a nice way of doing this.
            % TODO - a hacky way may be to get the cluster environment variables and
            % get the value of CCP_CLUSTER_NAME.  CCP_CLUSTER_NAME is present by default and
            % it appears that it is read-only, but there is no documentation to indicate that
            % this is really the case.  In fact,  Microsoft's documentation seems to imply
            % that CCP_CLUSTER_NAME _can_ be changed, although it is not something that users
            % would generally wish to do:
            % http://technet.microsoft.com/en-us/library/cc720153%28WS.10%29.aspx
            obj.SchedulerConnection = schedulerConnection;

            obj.SchedulerHostname = schedulerHostname;
            % Check to see if broker nodes are available - this determines whether or not
            % the cluster can run SOA jobs
            if ~obj.brokerNodesAvailable
                error('distcomp:AbstractHPCServerSOAConnection:SOANotSupported', ...
                    'SOA Jobs are not supported on scheduler with name %s', schedulerHostname)
            end
        end
        
        %---------------------------------------------------------------
        % submitJob
        %---------------------------------------------------------------
        function [jobIDs, jobName] = submitJob(obj, jobID, jobLocation, ...
                taskIDs, taskLocations, taskLogLocations, jobTemplate, ...
                matlabExe, matlabArgs, jobEnvironmentVariables, username, password)
            
            dotnetEnvironmentVariables = iConvertCellstrToDotNetDictionaryString(jobEnvironmentVariables);
            % And now do the actual job submission
            [jobIDs, jobName] = obj.doJobSubmission(jobID, jobLocation, ...
                taskIDs, taskLocations, taskLogLocations, jobTemplate, ...
                matlabExe, matlabArgs, dotnetEnvironmentVariables, username, password);
        end
    end
    
    methods (Abstract)
        closeJob(obj, hpcServerJobID, jobName);
    end
    
    
    methods (Abstract, Access = protected)
        [jobIDs, jobName] = doJobSubmission(obj, jobID, jobLocation, ...
            taskIDs, taskLocations, taskLogLocations, jobTemplate, ...
            matlabExe, matlabArgs, environmentVariableDictionary, username, password);
    end
    
    
    methods (Access = private)
        %---------------------------------------------------------------
        % brokerNodesAvailable
        %---------------------------------------------------------------
        function available = brokerNodesAvailable(obj)
            try
                brokerNodes = obj.SchedulerConnection.GetNodesInNodeGroup('WCFBrokerNodes');
                available = brokerNodes.Count > 0;
            catch err %#ok<NASGU>
                available = false;
            end
        end
    end
end

%---------------------------------------------------------------------
% iIsNetworkInstall
%---------------------------------------------------------------------
function result = iIsNetworkInstall
result = false;

fullMatlabRoot = dctReplaceDriveWithUNCPath(matlabroot);
if ~isempty(regexp(fullMatlabRoot, '^\\\\', 'once'))
    result = true;
end
end

%---------------------------------------------------------------------
% iConvertCellstrToDotNetDictionaryString
%---------------------------------------------------------------------
function dotNetDictionaryString = iConvertCellstrToDotNetDictionaryString(cellArrayOfStrings)
dictionarySize = size(cellArrayOfStrings, 1);
dotNetDictionaryString = NET.createGeneric('System.Collections.Generic.Dictionary', ...
    {'System.String', 'System.String'}, dictionarySize);
for ii = 1:dictionarySize
    dotNetDictionaryString.Add(cellArrayOfStrings{ii, 1}, cellArrayOfStrings{ii,2});
end
end
