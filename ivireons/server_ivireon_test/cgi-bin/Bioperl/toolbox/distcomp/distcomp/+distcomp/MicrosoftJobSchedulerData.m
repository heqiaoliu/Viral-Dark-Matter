classdef MicrosoftJobSchedulerData
    %MicrosoftJobSchedulerData Class for Job Scheduler Data associated with Micsrosoft Scheduler Jobs.
    %   Class to hold Job Scheduler Data associated with Micsrosoft Scheduler Jobs.

    %  Copyright 2009-2010 The MathWorks, Inc.

    %  $Revision: 1.1.6.3 $  $Date: 2010/04/21 21:14:34 $
    
    properties (SetAccess = private)
        % The version of the API used to submit the job (from the MATLAB
        % of view - not the actual version of the Microsoft API, which may
        % be diffferent).  
        % This value should be the same as the value returned by
        % AbstractMicrosoftSchedulerConnection.getAPIVersion
        % NB this is either 'CCS' or 'HPCServer2008'
        APIVersion;
        % The actual version of the scheduler to which this job was submitted.
        % This corresponds to the Major version of the scheduler 
        % CCS = 1, HPC Server 2008 = 2, HPC Server 2008 R2 = 3.
        % This value should be the same as the value returned by 
        % AbstractMicrosoftSchedulerConnection.SchedulerVersion
        SchedulerVersion;
        % The hostname of the scheduler to which we issued the job
        SchedulerName;
        % True/false indicating if this is an SOA job
        IsSOAJob;
        % The name of the job on the scheduler.
        SchedulerJobName;
        % The scheduler's job ID for this job
        SchedulerJobID;
        % The additional job ID for this job (to accommodate the fact that
        % SOA jobs have 2 job IDS associated with them)
        SchedulerAdditionalJobID;
        % The scheduler's task ID for each task - NOTE for parallel jobs where
        % there is only one actual task, every real task will map to the same
        % scheduler task ID
        SchedulerTaskIDs;
        % The IDs of the distcomp.abstracttask associated with a scheduler task
        % the field above.  If IsSOAJob==false, it is an error for MatlabTaskIDs
        % and SchedulerTaskIDs to be of different lengths.  We don't expect
        % SchedulerTaskIDs for SOA jobs.
        MatlabTaskIDs;
        % The log location relative to the storage location.
        LogRelativeToStorage;
        % The token in LogRelativeToStorage that needs to be replaced with the 
        % task ID in order to get the actual log location
        LogTaskIDToken;
    end
    
    properties (Constant)
        % Lower case type property to maintain consistency with the job scheduler
        % data for other scheduler types.  Hopefully this property will eventually
        % disappear.  
        type = 'hpcserver';
    end
    
    methods
        %---------------------------------------------------------------
        % MicrosoftJobSchedulerData constructor
        %---------------------------------------------------------------
        function obj = MicrosoftJobSchedulerData(apiVersion, schedulerVersion, schedulerHostname, ...
                isSOAJob, schedulerJobName, schedulerJobID, schedulerAdditionalJobID, ...
                schedulerTaskIDs, matlabTaskIDs, logRelativeToStorage, logTaskIDToken)
                
            % Parse inputs
            inputChecker = inputParser;
            inputChecker.FunctionName = 'MicrosoftJobSchedulerData';
            inputChecker.addRequired('apiVersion', @ischar);
            inputChecker.addRequired('schedulerVersion', @isnumeric);
            inputChecker.addRequired('schedulerHostname', @ischar);
            inputChecker.addRequired('isSOAJob', @islogical);
            inputChecker.addRequired('schedulerJobName', @ischar);
            inputChecker.addRequired('schedulerJobID', @isnumeric);
            inputChecker.addRequired('schedulerAdditionalJobID', @isnumeric);
            inputChecker.addRequired('schedulerTaskIDs', @isnumeric);
            inputChecker.addRequired('matlabTaskIDs', @isnumeric);
            inputChecker.addRequired('logRelativeToStorage', @ischar);
            inputChecker.addRequired('logTaskIDToken', @ischar);
            
            inputChecker.parse(apiVersion, schedulerVersion, schedulerHostname, ...
                isSOAJob, schedulerJobName, schedulerJobID, schedulerAdditionalJobID, ...
                schedulerTaskIDs, matlabTaskIDs, logRelativeToStorage, logTaskIDToken);
            
            % Check that we've got the correct combination of SOA/jobIds/taskIds.
            % SOA Jobs must not have scheduler task IDs.  Non-SOA jobs must have the same number
            % of scheduler task IDs and Matlab task IDs.
            if isSOAJob
                if ~isempty(schedulerTaskIDs)
                    error('distcomp:MicrosoftJobSchedulerData:InvalidArguments', ...
                        'SchedulerTaskIDs must be empty for SOA jobs');
                end
                % No longer check for the additional job ID as HPC Server 2008 R2 only 
                % has one SOA job ID.
            else
                if length(schedulerTaskIDs) ~= length(matlabTaskIDs)
                    error('distcomp:MicrosoftJobSchedulerData:InvalidArguments', ...
                        'SchedulerTaskIDs and MatlabTaskIDs must be the same length for non-SOA jobs.');
                end
            end
            
            obj.APIVersion = apiVersion;
            obj.SchedulerVersion = schedulerVersion;
            obj.SchedulerName = schedulerHostname;
            obj.IsSOAJob = isSOAJob;
            obj.SchedulerJobName = schedulerJobName;
            % Ensure that the job and task IDs are columns
            obj.SchedulerJobID = schedulerJobID(:);
            obj.SchedulerAdditionalJobID = schedulerAdditionalJobID(:);
            obj.SchedulerTaskIDs = schedulerTaskIDs(:);
            obj.MatlabTaskIDs = matlabTaskIDs(:);
            obj.LogRelativeToStorage = logRelativeToStorage;
            obj.LogTaskIDToken = logTaskIDToken;
        end
        
        function microsoftTaskID = getMicrosoftTaskIDFromMatlabID(obj, matlabTaskID)
            if isempty(obj.SchedulerTaskIDs)
                % SOA jobs will have no Microsoft task IDs.
                microsoftTaskID = [];
            else
                index = zeros(size(matlabTaskID));
                for i = 1:numel(matlabTaskID)
                    index(i) = find(matlabTaskID(i) == obj.MatlabTaskIDs, 1);
                end
                microsoftTaskID = obj.SchedulerTaskIDs(index);
                
                % In case a row vector was passed in, transpose
                % microsoftTaskID to be a row vector as well.
                % (obj.SchedulerTaskIDs is always a column)
                if size(matlabTaskID, 1) == 1
                    microsoftTaskID = microsoftTaskID';
                end
            end
        end
    end
end

