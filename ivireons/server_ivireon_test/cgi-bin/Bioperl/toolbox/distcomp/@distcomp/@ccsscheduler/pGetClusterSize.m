function val = pGetClusterSize(obj, val)
; %#ok Undocumented

%  Copyright 2009 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $  $Date: 2009/04/15 22:57:50 $

if isempty(obj.ServerConnection)
    return;
end

% Ask the server connection what the MaximumNumberOfWorkersPerJob should be.
val = obj.ServerConnection.MaximumNumberOfWorkersPerJob;
