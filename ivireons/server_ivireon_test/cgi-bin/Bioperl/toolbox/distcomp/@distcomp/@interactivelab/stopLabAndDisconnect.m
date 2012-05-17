function stopLabAndDisconnect(obj) %#ok obj never used.
; %#ok Undocumented
%stopLabAndDisconnect Stop pmode, destroy Java objects and close sockets.

% Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.6.4 $   $Date: 2008/06/24 17:01:16 $

% Destroy the Java objects for this pmode session, including the sockets.
try 
    com.mathworks.toolbox.distcomp.pmode.SessionFactory.destroyLabSession;
    com.mathworks.toolbox.distcomp.pmode.MatlabOutputWriters.getInstance.teardown();
    % Clean up memory associated with Composites
    spmdlang.ValueStore.clear();
catch err
    dctSchedulerMessage(1, ['Failed to destroy session object ', ...
                        'with message:\n''%s'''], err.message);
    rethrow(err);
end

