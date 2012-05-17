function varargout = getDebugLog( pbs, jobOrTask )
%getDebugLog - return the debug log for an PBS job or task
%   getDebugLog( pbs, job ) returns any output written to the standard
%   output or standard error streams by a parallel job
%
%   getDebugLog( pbs, task ) returns any output written to the standard
%   output or standard error streams by a non-parallel task.

%  Copyright 2007 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $    $Date: 2008/05/05 21:36:39 $

if isa( jobOrTask, 'distcomp.abstracttask' )
    task = jobOrTask;
    job  = task.Parent;
    whatWasGiven = sprintf( 'Task with ID %d', task.ID );
    stateOfThing = task.State;
elseif isa( jobOrTask, 'distcomp.simpleparalleljob' )
    task = [];
    job  = jobOrTask;
    whatWasGiven = sprintf( 'Job with ID %d', job.ID );
    stateOfThing = job.State;
else
    error( 'distcomp:pbsscheduler:badarg', ...
           'getDebugLog must be called with either a parallel job or a serial task' );
end

data = job.pGetJobSchedulerData;

if isempty( data )
    % Job not yet submitted?
    return;
end
if ~strcmp( data.type, 'pbs' )
    % Not our type
    return;
end

% Work out the PBS identifier for what we've got
if isa( jobOrTask, 'distcomp.abstracttask' )
    pbsIdString = pbs.pCalcTaskIdentifier( task, data );
else
    pbsIdString = data.pbsJobIds{1};
end


% Only return anything if output arguments were requested. Otherwise we'll
% display our results later.
if nargout > 0
    varargout = {''};
end

if ~isempty( task ) && isa( job, 'distcomp.simpleparalleljob' )
    % No task specified, given a serial job - no log file for the whole job
    warning( 'distcomp:pbsscheduler:nologfile', ...
             ['There is no log file for %s because it is part of a parallel job.\n', ...
              'Check the log for Job %d'], whatWasGiven, job.ID );
    return;
end

if isempty( task ) && ~isa( job, 'distcomp.simpleparalleljob' )
    % Task within a parallel job specified - no log file for this
    warning( 'distcomp:pbsscheduler:nologfile', ...
             ['There is no log file for %s because it is not a parallel job.\n', ...
              'Check the log for one of the tasks of Job %d'], whatWasGiven, job.ID );
    return;
end
    
% Calculate the full filename
fnameRel = data.relLogLocation;
fnameAbs = data.absLogLocation;

if ~isempty( task )
    % Need to replace "^array_index^" with array index
    allTaskIds = get( job.Tasks, 'ID' );
    if iscell( allTaskIds )
        allTaskIds = cell2mat( allTaskIds );
    end
    arrayIndex = find( allTaskIds == task.ID, 1, 'first' );
    fnameRel = strrep( fnameRel, '^array_index^', num2str( arrayIndex ) );
    fnameAbs = strrep( fnameAbs, '^array_index^', num2str( arrayIndex ) );
end

out = '';

storage        = job.pReturnStorage;
logRoot        = storage.StorageLocation;

% No relative location in certain circumstances on PC - in which case, fall
% back to the absolute location
if isempty( fnameRel )
    fnameCanonical = fnameAbs;
else
    fnameCanonical = fullfile( logRoot, fnameRel );
end

if ~exist( fnameCanonical, 'file' ) && ~ismember( stateOfThing, {'finished', 'failed'} )
    warning( 'distcomp:pbsscheduler:nologfile', ...
             'The PBS output log is not yet present - this is only written after the job or task completes' );
    [FAILED, out] = pbs.pPbsSystem( sprintf( 'qstat -f "%s"', ...
                                             pbsIdString ) );
    if FAILED
        warning( 'distcomp:pbsscheduler:infofailed', ...
                 'An attempt to extract information using "qstat -f" failed: \n%s', out );
    end
elseif ismember( stateOfThing, {'finished', 'failed'} ) && ~exist( fnameCanonical, 'file' )
    warning( 'distcomp:pbsscheduler:nologfile', ...
             'The %s is in the state "%s", but there is no log file present.', ...
             whatWasGiven, stateOfThing );
else
    fh = fopen( fnameCanonical, 'rt' );
    if fh == -1
        error( 'distcomp:pbsscheduler:cantreadlog', ...
               'Could not read output from file: %s', fnameCanonical );
    end

    try
        out = fread( fh, Inf, 'char' );
        % Delete \r - these occur in DOS log files, and cause the display on UNIX to
        % have spurious linebreaks.
        out( out == sprintf( '\r' ) ) = [];
        out = sprintf( 'Log file: %s\n%s', ...
                       fnameCanonical, char( out.' ) );
        err = '';
    catch exception
        err = exception;
    end
    % Always close the file
    fclose( fh );
    if ~isempty( err )
        error( 'distcomp:pbsscheduler:errorreadinglog', ...
               '%s', err.message );
    end
end

totalOut = out;
if nargout > 0
    varargout = {totalOut};
else
    disp( totalOut );
end