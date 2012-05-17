function connMgr = pCreateConnectionManager( obj )
; %#ok Undocumented
% pCreateConnectionManager returns a newly created ConnectionManager object
%   Reads the portrange from pctconfig. Throws an error if no port in that range
%   can be bound.

% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $   $Date: 2009/04/15 22:58:24 $

import com.mathworks.toolbox.distcomp.pmode.io.ConnectionManager;

cfg       = pctconfig();
portrange = cfg.portrange;
% portrange will be either [minPort, maxPort] or 0
useEphemeral = isscalar(portrange);
constants    = distcomp.getInteractiveConstants();

if useEphemeral
    connMgr = ConnectionManager.buildClientConnManager(0, constants.connectionBacklog);
else
    try
        connMgr = ConnectionManager.buildClientConnManager(portrange(1), portrange(2), ...
                                                           constants.connectionBacklog);
    catch err
        % The only exception that we expect to catch is a failure to bind to the
        % requisite port. ConnectionManager throws a bind exception if it fails
        % to bind to any port in the provided range.
        [isJavaError, exceptionType] = isJavaException(err);
        if isJavaError && strcmp(exceptionType, 'java.net.BindException')
            error('distcomp:interactive:PortInUse', ...
                  ['All ports in the range [%d, %d] are already in use. ', ...
                   'Type   pctconfig(''portrange'', [minPort, maxPort])   ', ...
                   'to configure an interactive session ', ...
                   'to use the port range specified by [minPort, maxPort].'], ...
                  portrange(1), portrange(2));
        else 
            rethrow(err)
        end
    end
end
obj.ConnectionManager = connMgr;
