function OK = stopLabsAndDisconnect(obj)
; %#ok Undocumented.
%stopLabsAndDisconnect Stop all the labs and perform client cleanup
%   Send the stop signal to all the labs so they exit.  Clean up sockets
%   and streams.

% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $    $Date: 2009/12/03 19:00:10 $

OK = true;
if ~obj.IsClientOnlySession
    OK = obj.pStopLabsAndDisconnect();
end

% Clean up memory associated with Composites
spmdlang.ValueStore.clear();
