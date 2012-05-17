function start(obj, leadingTaskNum)
; %#ok Undocumented
%START Start matlabpool job client.

% Copyright 2007-2008 The MathWorks, Inc.

% $Revision: 1.1.6.9 $    $Date: 2009/01/20 15:31:26 $

% If we are running just on the client none of the following is needed.
if obj.IsClientOnlySession
    return
end

try 
    connMgr = obj.pCreateConnectionManager();
catch err
    obj.pStopLabsAndDisconnect();
    rethrow(err);
end

% We need the name of this machine to connect back to from the parallel
% job.  Get from pctconfig as it allows the user to override the default
% hostname.
cfg = pctconfig();
hostname = cfg.hostname;

% Build the SocketAddress to connect back to - allowing the user to override
% the hostname. The InetSocketAddress constructor throws no exceptions.
% TODO: Here, we override the hostname from original socket address. Is that
% really the right thing to do?
origSockAddr = connMgr.getAddress();
sockAddr = java.net.InetSocketAddress( hostname, origSockAddr.getPort() );

% Share the hostname and port among all labs. The corresponding MPI call
% resides in @matlabpoolab/start.m
sockAddr = labBroadcast(leadingTaskNum, sockAddr); %#ok<NASGU>

% Set up for SPMD execution - build the new communicator, and stash
% that for later. 
try
    % Corresponding mpiCommManip is in the labs' "start" method
    newWorld = mpiCommManip( 'split', -1, labindex );
    worldVec = gcat( {newWorld} );
    spmdlang.commForWorld( 'set', worldVec(2:end), 2 );
    % Deadlock detection on for now while we don't have a good way of
    % interrupting non-dd communications
    mpiSettings( 'DeadlockDetection', 'on' );
catch err
    obj.pStopLabsAndDisconnect();
    rethrow( err );
end

% Wait for the labs to connect back to the client.
try
    schans = obj.pGetSockets();
catch err
    % pGetSockets rewrites the error.
    obj.pStopLabsAndDisconnect();
    rethrow(err);
end

% Create the Java objects for this interactive session.
try
    % SessionFactory takes ownership of the Sockets as well as the Session.
    com.mathworks.toolbox.distcomp.pmode.SessionFactory.createClientSession(schans);
    session = com.mathworks.toolbox.distcomp.pmode.SessionFactory.getCurrentSession();
    % Once created we should loop waiting for all labs to finish starting
    % up
    while ~session.waitForSessionToStart(100, java.util.concurrent.TimeUnit.MILLISECONDS);
    end
catch err
    obj.pStopLabsAndDisconnect();
    throw( MException(err.identifier,...
        'Failed to initialize the interactive session.\nThis is caused by:\n%s', err.message) );
end

% For a matlabpool session tell the session to listen for Path and Clear
% notification and send them onto the labs
try
    session.startSendPathAndClearNotificationToLabs;
    dctPathAndClearNotificationGateway('on');
    mpiCommManip( 'select', 'self' );
catch err
    obj.pStopLabsAndDisconnect();
    throw( MException(err.identifier,...
        'Failed to initialize the interactive session.\nThis is caused by:\n%s', err.message) );
end
