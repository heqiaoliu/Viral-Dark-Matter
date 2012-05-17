function connMgr = pCreateConnectionManager( obj ) 
; %#ok Undocumented
% pCreateConnectionManager returns a newly created ConnectionManager object
% Currently uses an ephemeral port

% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $   $Date: 2009/04/15 22:58:30 $

import com.mathworks.toolbox.distcomp.pmode.io.ConnectionManager;

% Ideally we'd provide a way to specify the portrange to use here, but
% for now we'll use port = 0 to specify an ephemeral port.
port = 0;
constants = distcomp.getInteractiveConstants();
connMgr = ConnectionManager.buildClientConnManager( port, constants.connectionBacklog );
obj.ConnectionManager = connMgr;


