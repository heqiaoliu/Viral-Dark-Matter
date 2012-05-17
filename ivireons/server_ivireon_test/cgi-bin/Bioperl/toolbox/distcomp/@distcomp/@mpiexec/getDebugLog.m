function out = getDebugLog( mpiexec, job )
%getDebugLog - return output messages from parallel job run by mpiexec scheduler
%
%    getDebugLog(mpiexecObj, job) returns any output written to the standard
%    output or standard error streams by the job identified by job, being run by
%    the scheduler identified by mpiexecObj.
%    Example:
%    % Construct the scheduler object so we can proceed to create a parallel
%    % job.  We assume that there exists a configuration called 'mpiexec'.
%    mpiexecObj = findResource('scheduler', 'Configuration', 'mpiexec');
%    % Complete the initialization of the scheduler object by setting all the
%    % necessary properties on it.
%    set(mpiexecObj, 'Configuration', 'mpiexec');
%    % Create and submit a parallel job.
%    job = createParallelJob(mpiexecObj);
%    createTask(job, @labindex, 1, {});
%    submit(job);
%    % Look at the debug log.
%    getDebugLog(mpiexecObj, job);

%  Copyright 2005-2008 The MathWorks, Inc.
%  $Revision: 1.1.10.5 $    $Date: 2008/05/05 21:36:32 $

data = job.pGetJobSchedulerData;
out = '';
if isempty( data )
    % Job not yet submitted?
    return;
end
if ~strcmp( data.type, 'mpiexec' )
    % error?
    return;
end

fname = mpiexec.pJobSpecificFile( job, '.mpiexec.out' );
fh = fopen( fname, 'rt' );
if fh == -1
    error( 'distcomp:mpiexec:cantreadstdout', ...
           'Could not read job output from file: %s', fname );
end

try
    out = fread( fh, Inf, 'char' );
    out = char( out.' );
    err = '';
catch exception
    err = exception;
end
% Always close the file
fclose( fh );
if ~isempty( err )
    error( 'distcomp:mpiexec:errorreadingstdout', ...
           '%s', err.message );
end

