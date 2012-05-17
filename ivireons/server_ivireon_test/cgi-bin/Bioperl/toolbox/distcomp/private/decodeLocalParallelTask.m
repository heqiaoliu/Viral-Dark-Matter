function runprop = decodeLocalParallelTask(runprop)

% Copyright 2004-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.6.2.1 $    $Date: 2010/06/24 19:32:58 $

% Get a function handle to set status messages for lsf on this particular
% task - this will set the default message handler to be lsfSet
dctSchedulerMessage(2, 'In decodeLocalParallelTask');

sentialLocation     = getenv('MDCE_SENTINAL_LOCATION');
numLabsStr          = getenv('MDCE_NUMLABS');
labIndexStr         = getenv('MDCE_LABINDEX');

storageConstructor  = getenv('MDCE_STORAGE_CONSTRUCTOR');
storageLocation     = urldecode( getenv('MDCE_STORAGE_LOCATION') );
jobLocation         = getenv('MDCE_JOB_LOCATION');
taskLocation        = [jobLocation filesep 'Task' labIndexStr ];

    
set(runprop, ...
    'StorageConstructor', storageConstructor, ...
    'StorageLocation', storageLocation, ...
    'JobLocation', jobLocation, ....
    'TaskLocation', taskLocation);

% Ensure that on unix we mask SIGINT and SIGSTOP as the shell 
% will send these signals to all members of the main MATLAB
% process group. Thus we will replace the handlers with functions
% that do nothing so we are unaffected by these signals
if isunix
    dctInstallLocalSignalHandler
end

try
    iParallelConnection(sentialLocation, str2double(labIndexStr), ...
                        str2double(numLabsStr));
catch err
    dctSchedulerMessage(1, 'Error in iParallelConnection :\n%s', ...
                        err.message);
    rethrow(err);
end



%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function iParallelConnection( fnameroot, taskID, expectedNumlabs )

fname_sentinel = [fnameroot, '.lock'];
fname_port     = [fnameroot, '.port'];

% Create a CancelWatchdog to make sure it doesn't take us too long to
% connect/accept.
import com.mathworks.toolbox.distcomp.util.CancelWatchdog;
exitCode = 1;
timeout = 480;
cw = CancelWatchdog( exitCode, timeout );

if taskID == 1
    % Ensure the sentinel exists
    fh = fopen( fname_sentinel, 'wt' );
    fclose( fh );
    
    % Open the port and set the parallel tag
    port = mpigateway( 'openport' );
    fh = fopen( fname_port, 'wt' );
    if fh == -1
        error( 'Couldn''t write port information to: %s', fname_port );
    end
    fprintf( fh, '%s\n', port );
    fclose( fh );
    
    % Delete the sentinel to indicate that we're ready
    delete( fname_sentinel );

    % Now, the other labs start looking out
    mpigateway( 'servaccept', port, expectedNumlabs - 1 );
    
    % Delete the port file because we're done with it now
    delete( fname_port );
else
    % wait until the port file exists
    while ~exist( fname_port, 'file' )
        pause(0.5);
    end
    % now wait until the sentinel file has gone - this indicates that lab 1
    % has finished writing and closed the port file
    while exist( fname_sentinel, 'file' )
        pause( 0.5 );
    end
    % Read the port
    fh = fopen( fname_port, 'rt' );
    if fh == -1
        error( 'Couldn''t read port information from: %s', ...
               fname_port );
    end
    port = fgetl( fh );
    fclose( fh );
    
    % Perform the connection
    mpigateway( 'clientconn', port, expectedNumlabs - 1 );
end
% Indicate to the CancelWatchdog that we have passed the time-critical
% point
cw.ok();

% Sort out the ordering
tasksByIndex = gcat( taskID );
[~, desOrder] = sort( tasksByIndex ); 
mpigateway( 'desiredlabordering', desOrder );
