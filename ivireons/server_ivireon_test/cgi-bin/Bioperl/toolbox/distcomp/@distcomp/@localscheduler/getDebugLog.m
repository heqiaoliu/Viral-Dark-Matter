function varargout = getDebugLog( local, jobOrTask ) %#ok<INUSL>
%getDebugLog - return the debug log for an LOCAL job or task
%   getDebugLog( local, job ) returns any output written to the standard
%   output or standard error streams by a parallel job
%
%   getDebugLog( local, task ) returns any output written to the standard
%   output or standard error streams by a non-parallel task.

%  Copyright 2006-2008 The MathWorks, Inc.

%  $Revision: 1.1.6.5 $    $Date: 2008/05/05 21:36:16 $

% Do input type checking and setup valid task and job objects
if isa( jobOrTask, 'distcomp.abstracttask' )
    % Task of a simplejob
    task = jobOrTask;
    job  = task.Parent;
    % Check we are part of a valid simplejob
    if ~isa( job, 'distcomp.simplejob' )
        % No task specified, given a serial job - no log file for the whole job
        warning( 'distcomp:localscheduler:NoLogFile', ...
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
        warning( 'distcomp:localscheduler:NoLogFile', ...
            ['There is no log file for Job with ID %d because it is not a parallel job.\n', ...
            'Check the log for one of the tasks of Job %d'], job.ID, job.ID );
        return;
    end
    stateOfJob = job.State;
    GIVEN_A_TASK = false;
else
    error( 'distcomp:localscheduler:InvalidArgument', 'The input to getDebugLog should be either a job or task from a local scheduler');
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
if ~strcmp( data.type, 'local' )
    % Not our type
    % warning ?
    return;
end

% Lets try and see if the log file we are looking for exists
if ~isempty( data.logRelToStorage )
    logRelativeToRoot = data.logRelToStorage;
    logRoot = job.pReturnStorage.StorageLocation;
    % If we are looking at the log for a task then append the taskID to the
    % end of the request
    if GIVEN_A_TASK 
        logLocation = sprintf('%s%s%s%d.log', logRoot, filesep, logRelativeToRoot, task.ID);
    else
        logLocation = sprintf('%s%s%s', logRoot, filesep, logRelativeToRoot);
    end
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
        cellout{end+1} = sprintf('Unable to find log file :\n%s\n\n', logLocation);
    end
    if JOB_FAILED 
        % TODO - pick up exit code from processes?
    end
    out = sprintf('%s', cellout{:});
else
    warning( 'distcomp:localscheduler:NoLogFilePresent', ...
        'The local output log is not yet present - this is only written after the job or task starts running' );
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
    error( 'distcomp:localscheduler:FilePermissionError', ...
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
    error( 'distcomp:localscheduler:FilePermissionError', ...
        '%s', err.message );
end

