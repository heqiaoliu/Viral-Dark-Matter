function OK = pStopLabsAndDisconnect(obj)
; %#ok Undocumented.
%stopLabsAndDisconnect Stop all the labs and perform client cleanup
%   Send the stop signal to all the labs so they exit.  Clean up sockets
%   and streams.

%   Copyright 2007-2009 The MathWorks, Inc.

% $Revision: 1.1.6.7 $    $Date: 2009/12/03 19:00:09 $

% Must ensure we are all back in the world communicator to clean up.
mpiCommManip( 'select', 'world' );

OK = true;
if ~isempty(com.mathworks.toolbox.distcomp.pmode.SessionFactory.getCurrentSession)
    disp('Sending a stop signal to all the labs...');
    dctPathAndClearNotificationGateway('off');
    OK = com.mathworks.toolbox.distcomp.pmode.SessionFactory.destroyClientSession;
end

if ~isempty(obj.ConnectionManager)
    try
        obj.ConnectionManager.close;
    catch err
        dctSchedulerMessage(2, ['Failed to close the server socket due to the ', ...
                            'following error:\n%s'], err.message);
    end
end
% Finished with the ConnectionManager - forget about it
obj.ConnectionManager = [];
end
