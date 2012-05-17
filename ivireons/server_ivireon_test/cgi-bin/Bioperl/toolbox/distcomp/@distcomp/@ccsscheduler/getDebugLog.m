function varargout = getDebugLog( ccs, jobOrTask )
%getDebugLog - return the debug log for an CCS job or task
%   getDebugLog( ccs, job ) returns any output written to the standard
%   output or standard error streams by a parallel job
%
%   getDebugLog( ccs, task ) returns any output written to the standard
%   output or standard error streams by a non-parallel task.

%  Copyright 2006-2009 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $    $Date: 2009/04/15 22:57:44 $

% Do input type checking and setup valid task and job objects
if isa( jobOrTask, 'distcomp.abstracttask' )
    % Task of a simplejob
    task = jobOrTask;
    job  = task.Parent;
    % Check we are part of a valid simplejob
    if ~isa( job, 'distcomp.simplejob' )
        % No task specified, given a serial job - no log file for the whole job
        warning( 'distcomp:ccsscheduler:nologfile', ...
            ['There is no log file for Task with ID %d because it is part of a parallel job.\n', ...
            'Check the log for Job %d'], task.ID, job.ID );
        return;
    end
    % Always defer to state of job as this will pick up the failed situation
    % that tasks will never see
    stateOfJob = job.State;
    GIVEN_A_TASK = true;
elseif isa( jobOrTask, 'distcomp.abstractjob' )
    % Should be a parallel job
    task = [];
    job  = jobOrTask;
    % Check we are part of a valid simpleparalleljob
    if ~isa( job, 'distcomp.simpleparalleljob' )
        % Task within a parallel job specified - no log file for this
        warning( 'distcomp:ccsscheduler:nologfile', ...
            ['There is no log file for Job with ID %d because it is not a parallel job.\n', ...
            'Check the log for one of the tasks of Job %d'], job.ID, job.ID );
        return;
    end
    stateOfJob = job.State;
    GIVEN_A_TASK = false;
else
    error( 'distcomp:ccsscheduler:InvalidArgument', 'The input to getDebugLog should be either a job or task from an HPC Server scheduler');
end

data = job.pGetJobSchedulerData;

% Only return anything if output arguments were requested. Otherwise we'll
% display our results later.
if nargout > 0
    varargout = {''};
end

if isempty( data )
    % Job not yet submitted?
    return;
end
if ~isa(data, 'distcomp.MicrosoftJobSchedulerData')
    % Not our type
    % warning ?
    return;
end

% Lets try and see if the log file we are looking for exists
if ~isempty( data.LogRelativeToStorage )
    logRelativeToRoot = data.LogRelativeToStorage;
    logRoot = job.pReturnStorage.StorageLocation;
    % If we are looking at the log for a task then replace the token with the task ID
    if GIVEN_A_TASK
        relLogLocation = strrep(logRelativeToRoot, data.LogTaskIDToken, num2str(task.ID));
    else
        relLogLocation = logRelativeToRoot;
    end
    logLocation = sprintf('%s\\%s', logRoot, relLogLocation);
end


% Has the job or task finished?
JOB_IS_FINISHED = ismember( stateOfJob, {'finished', 'failed'} );
JOB_FAILED = strcmp( stateOfJob, 'failed');
LOG_EXISTS = exist( logLocation, 'file' );
% If the log exists then the thing will have started running - if the job
% is finished and the log doesn't exist then either matlab didn't start up
% at all, or doesn't have write access to the file system
if LOG_EXISTS || JOB_IS_FINISHED
    cellout = {};
    if LOG_EXISTS
        cellout{end+1} = sprintf('LOG FILE OUTPUT:\n');
        cellout{end+1} = iReadLogfile( logLocation );
    else
        % Getting here indicates that the LOG doesn't exist and thus that
        % the job MUST be finished (and probably failed because the log
        % doesn't exist)
        cellout{end+1} = sprintf(['Unable to find log file :\n%s\n\n' ...
            'This situation could arise if :\n'...
            '1. HPC Server was unable to start matlab\n' ...
            '2. The remote machine is unable to write to the log file above, possibly because of\n' ...
            'file permissions or that local drive is not available from the remote host.\n'...
            ''], logLocation);
    end
    if JOB_FAILED
        ccsJobID = data.SchedulerJobID;
        if GIVEN_A_TASK
            % If this was an SOA job, then data.SchedulerTaskIDs will be empty, so just set
            % ccsTaskID to [].  This should still us details about the job
            if data.IsSOAJob
                ccsTaskID = [];
            else
                ccsTaskID = data.getMicrosoftTaskIDFromMatlabID(task.ID);
                % Did we find the relevant ccsTaskID?
                if isempty(ccsTaskID ) || numel(ccsTaskID ) > 1
                    warning('distcomp:ccsscheduler:cannotFindTask', ...
                        'Cannot find task in HPC Server scheduler');
                    ccsTaskID = [];
                end
            end
        else
            % This was a parallel job, so get the details for the first task.
            ccsTaskID = data.SchedulerTaskIDs(1);
        end
        s = pGetTempConnectionToScheduler(ccs, data.SchedulerName, data.APIVersion);
        cellout{end+1} = sprintf('\n\nHPC SERVER DATA OUTPUT:\n');
        cellout{end+1} = s.getSchedulerDetailsForFailedJob(ccsJobID, ccsTaskID);
    end
    out = sprintf('%s', cellout{:});
else
    warning( 'distcomp:ccsscheduler:nologfile', ...
        'The HPC Server output log is not yet present - this is only written after the job or task starts running' );
    out = '';
end

if nargout > 0
    varargout = {out};
else
    disp(out);
end


%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function out = iReadLogfile(logLocation)

fh = fopen( logLocation, 'rt' );
if fh == -1
    error( 'distcomp:ccsscheduler:cantreadlog', ...
        'Could not read output from file: %s', logLocation );
end

try
    out = fread( fh, Inf, 'char' );
    % Delete \r
    out( out == sprintf( '\r' ) ) = [];
    out = char( out.' );
    err = '';
catch exception
    err = exception;
end
% Always close the file
fclose( fh );
if ~isempty( err )
    error( 'distcomp:ccsscheduler:errorreadinglog', ...
        '%s', err.message );
end

