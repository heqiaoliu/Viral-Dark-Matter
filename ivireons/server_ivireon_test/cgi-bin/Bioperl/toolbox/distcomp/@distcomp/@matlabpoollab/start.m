function start(obj, leadingTaskNum)
; %#ok Undocumented
%start This will start a matlabpool job on the non-leading labs
%   The labs connect to the specified host and port and create their
%   session object.

% Copyright 2007-2008 The MathWorks, Inc.

% $Revision: 1.1.6.7 $    $Date: 2008/11/24 14:56:54 $

try
    leaderSockAddr = labBroadcast(leadingTaskNum);

    % Set up for SPMD execution - make a new MPI communicator that involves only
    % labs 2:numlabs.
    obj.NewWorldComms = mpiCommManip( 'split', 1, labindex );
    gcat( {obj.NewWorldComms} );

    % Deadlock detection on for now while we don't have a good way of
    % interrupting non-dd communications
    mpiSettings( 'DeadlockDetection', 'on' );

    obj.connectToClient( leaderSockAddr );
    
    mpiCommManip( 'select', obj.NewWorldComms );
catch err
    dctSchedulerMessage(1, 'Error message from matlabpoollab/start: %s', ...
                        err.message);
    rethrow(err);
end
