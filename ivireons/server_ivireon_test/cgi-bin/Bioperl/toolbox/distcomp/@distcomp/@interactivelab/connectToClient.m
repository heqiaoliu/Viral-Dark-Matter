function connectToClient(obj, sockAddr)
; %#ok Undocumented
%connecToClient Start pmode and connect to the client.
%   Lab opens a socket and connects back to the MATLAB client.  Errors if this
%   is not possible.

%   Copyright 2006-2008 The MathWorks, Inc.

import java.nio.channels.*;
import com.mathworks.toolbox.distcomp.pmode.io.ConnectionManager;


try
    
    % Build our ConnectionManager
    % TODO: maybe control the port that the labs open?
    % TODO: Backlog == numlabs?
    connMgr = ConnectionManager.buildLabConnManager( labindex, 0, 0 );
    
    % Register everyone's server address
    connMgr.registerAllLabAddresses( gcat( connMgr.getAddress() ) );
    clientProc = connMgr.registerClientAddress( sockAddr );
    
    % Force connections to occur in batches, so that we don't overflow the
    % ServerSocket's connection backlog setting.
    constants = distcomp.getInteractiveConstants;
    batchSize = constants.connectionBacklog - 1;

    for ii = 1:batchSize:numlabs
        if labindex >= ii && labindex < ii + batchSize
            % Perturb the connections
            pause(0.01 * (labindex-ii));
            
            schan = connMgr.activelyConnectTo( clientProc, numlabs );
            
        end
        labBarrier;
    end
    % Ensure that all labs reach this point simultaneously so that their 
    % "self-destruct" timers are approx. in sync.  See LabShutdownHandlerImpl.
    labBarrier;
catch err
    dctSchedulerMessage(1, 'Connection failed with the message:\n''%s''', ...
                        err.message);
    % Rewrite the error to explain what went wrong.
    [id, msg] = obj.pProcessConnectException(err, sockAddr);
    throw( MException(id, msg) );
end

% Create the Java objects for this pmode session.
try 
    % ConnectionManager is not needed from this point onwards
    connMgr.close();
    % Set up the streams for asynchronous output redirection
    com.mathworks.toolbox.distcomp.pmode.MatlabOutputWriters.getInstance.setup();
    % SessionFactory takes ownership of the Sockets as well as the Session.
    com.mathworks.toolbox.distcomp.pmode.SessionFactory.createLabSession(schan, labindex);
catch err
    dctSchedulerMessage(1, ['Failed to create session object with ', ...
                        'the message:\n''%s'''], err.message);
    rethrow(err);
end
