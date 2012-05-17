function stopLabAndDisconnect(obj)
; %#ok Undocumented
%stopLabAndDisconnect Stop pmode, destroy Java objects and close sockets.

% This is not quite a 1:1 copy of @interactivelab/stopLabAndDisconnect.m -
% as we need to free the "NewWorldComms"

% Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.6.5 $   $Date: 2008/08/08 12:51:40 $


% Destroy the Java objects for this pmode session, including the sockets.
try 
    mpiCommManip( 'select', 'world' );
    com.mathworks.toolbox.distcomp.pmode.SessionFactory.destroyLabSession;
    com.mathworks.toolbox.distcomp.pmode.MatlabOutputWriters.getInstance.teardown();
    mpiCommManip( 'free',   obj.NewWorldComms );
    % Clean up memory associated with Composites
    spmdlang.ValueStore.clear();
catch err
    dctSchedulerMessage(1, ['Failed to destroy session object ', ...
                        'with message:\n''%s'''], err.message);
    rethrow(err);
end

