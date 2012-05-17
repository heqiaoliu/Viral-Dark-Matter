function val = pGetJobDescriptionFile(ccs, val)
; %#ok Undocumented
% Get the job description file from the server connection

%  Copyright 2009 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $  $Date: 2009/04/15 22:57:54 $

if isempty(ccs.ServerConnection)
    return;
end

% Ask the server connection for the job description file.
val = ccs.ServerConnection.JobDescriptionFile;