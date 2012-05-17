function varargout = getDebugLog( lsf, jobOrTask )
%getDebugLog - return the debug log for an LSF job or task
%   getDebugLog( lsf, job ) returns any output written to the standard
%   output or standard error streams by a parallel job
%
%   getDebugLog( lsf, task ) returns any output written to the standard
%   output or standard error streams by a non-parallel task.

%  Copyright 2005-2008 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $    $Date: 2008/05/05 21:36:19 $

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
    error( 'distcomp:lsfscheduler:badarg', ...
           'getDebugLog must be called with either a parallel job or a serial task' );
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
if ~strcmp( data.type, 'lsf' )
    % Not our type
    return;
end

if ~isempty( task ) && isa( job, 'distcomp.simpleparalleljob' )
    % No task specified, given a serial job - no log file for the whole job
    warning( 'distcomp:lsfscheduler:nologfile', ...
             ['There is no log file for %s because it is part of a parallel job.\n', ...
              'Check the log for Job %d'], whatWasGiven, job.ID );
    return;
end

if isempty( task ) && ~isa( job, 'distcomp.simpleparalleljob' )
    % Task within a parallel job specified - no log file for this
    warning( 'distcomp:lsfscheduler:nologfile', ...
             ['There is no log file for %s because it is not a parallel job.\n', ...
              'Check the log for one of the tasks of Job %d'], whatWasGiven, job.ID );
    return;
end
    
if ~isfield( data, 'logRelToStorage' )
    % Old job (pre DCT v.3) - warn and return.
    warning( 'distcomp:lsfscheduler:nologfile', ...
             'There is no log file for %s', whatWasGiven );
    return;
end

% Calculate the full filename
fnameRel = data.logRelToStorage;

if ~isempty( task )
    % Need to replace "%I" with task ID
    fnameRel = strrep( fnameRel, '%I', num2str( task.ID ) );
    jobStrForBread = sprintf( '%d[%d]', data.lsfID, task.ID );
else
    jobStrForBread = num2str( data.lsfID );
end

% Pre-allocate both outputs in case we don't actually calculate them
breadOut = '';
out = '';

storage        = job.pReturnStorage;
logRoot        = storage.StorageLocation;
fnameCanonical = fullfile( logRoot, fnameRel );

if ~exist( fnameCanonical, 'file' ) && ~ismember( stateOfThing, {'finished', 'failed'} )
    warning( 'distcomp:lsfscheduler:nologfile', ...
             ['The LSF output log is not yet present - this is only written after the job or task completes.\n', ...
              'You could use the LSF command  bpeek "%s"  from the command-line to see partial output'], ...
             jobStrForBread );
elseif ismember( stateOfThing, {'finished', 'failed'} ) && ~exist( fnameCanonical, 'file' )
    warning( 'distcomp:lsfscheduler:nologfile', ...
             ['The %s is in the state "%s", but there is no log file present. Using \n', ...
              '"bread" to read any LSF messages'], whatWasGiven, stateOfThing );
    done = false;
    readIdx = 0;
    while ~done
        % When we get to the end of the list, unfortunately we will get an error message
        [a,b] = dctSystem( sprintf( 'bread -i %d %s', readIdx, jobStrForBread ) );
        if a == 0
            breadOut = sprintf( '%s\n%s', breadOut, b );
            readIdx = readIdx+1;
        else
            done = true;
        end
    end
else
    fh = fopen( fnameCanonical, 'rt' );
    if fh == -1
        error( 'distcomp:lsfscheduler:cantreadlog', ...
               'Could not read output from file: %s', fnameCanonical );
    end

    try
        out = fread( fh, Inf, 'char' );
        % Delete \r - these occur in DOS log files, and cause the display on UNIX to
        % have spurious linebreaks.
        out( out == sprintf( '\r' ) ) = [];
        out = char( out.' );
        err = '';
    catch exception
        err = exception;
    end
    % Always close the file
    fclose( fh );
    if ~isempty( err )
        error( 'distcomp:lsfscheduler:errorreadinglog', ...
               '%s', err.message );
    end
end

totalOut = sprintf( '%s\n%s', breadOut, out );
if nargout > 0
    varargout = {totalOut};
else
    disp( totalOut );
end