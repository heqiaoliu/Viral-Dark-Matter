function pMpiInit( job, task )
; %#ok Undocumented
%pMpiInit - initialise MPI for a parallel job

%  Copyright 2000-2009 The MathWorks, Inc.

%  $Revision: 1.1.10.7 $    $Date: 2009/10/12 17:27:49 $ 

% Force the "sock" option, as this is the only one that will work under the
% jobmanager.
mpiInit( 'sock' );

% This is a new parallel session
mpiParallelSessionStarting;

% "Leading task" is assigned by the JM during despatch of the job.
% Find out if this task is the leading task.
isleadingtask = job.pIsLeadingTask( task );

if isleadingtask
    % Open the port and set the parallel tag
    port = mpigateway( 'openport' );
    % Set the tag including the type of the computer
    ptag = sprintf( '%s\n%s', port, computer );
    job.pSetParallelTag( ptag );
end

% Extract parallel job setup info
pinfo = job.pGetParallelInfo;
% Wait until setup info is retrieved from the job manager.
while isempty( pinfo )
    pause( 0.5 ); % A shortish wait
    pinfo = job.pGetParallelInfo;
end

% Everyone needs to know the expected world size and the parallel tag.
num = pinfo.getNumLabs;
ptag = char( pinfo.getParallelTag );
[port, comp] = strtok( ptag, sprintf( '\n' ) );

% Create a CancelWatchdog to make sure it doesn't take us too long to
% connect/accept.
import com.mathworks.toolbox.distcomp.util.CancelWatchdog;

% Choose a timeout based on the expected number of labs.
timeout = max( 120, 4 * num );
cw = CancelWatchdog( job.ProxyObject, ...
                     job.UUID, ...
                     'Timeout exceeded during parallel connection', timeout );
err = [];
try
    if isleadingtask
        % accept the other connections - with timeout
        mpigateway( 'servaccept', port, num - 1 );
    else
        % We should never get a badly formatted tag, since the job is locked when
        % being modified.
        if isempty( comp )
            error( 'distcomp:mpi:init', 'Badly formatted parallel tag: <%s>', ptag );
        end
        comp = comp(2:end);
        
        % Check that the this computer is compatible with the computer which opened
        % the port
        iCompatCheck( comp );

        % Connect up
        mpigateway( 'clientconn', port, num - 1 );
    end
catch exception
    err = exception;
end
% We're OK - so call off the watchdog.
cw.ok();

% If connect/accept threw an error, rethrow that.
if ~isempty( err )
    rethrow( err );
end

% Set the labindex as desired
tasksByIndex = gcat( task.ID );
[junk, desOrder] = sort( tasksByIndex ); %#ok
mpigateway( 'desiredlabordering', desOrder );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iCompatCheck - check compatibility of computers. The criteria are that the
% word sizes and endianness must match. 
function iCompatCheck( comp )

import com.mathworks.toolbox.distcomp.pml.LabCompatibilityChecker;

mycomp = computer;
compatible = LabCompatibilityChecker.instance.areComputersCompatible(comp, mycomp);

if ~compatible
   error( 'distcomp:mpi:incompatible', ...
          'Compatibility check failed: worker type %s is not compatible with leading worker type %s', ...
          mycomp, comp );
end
