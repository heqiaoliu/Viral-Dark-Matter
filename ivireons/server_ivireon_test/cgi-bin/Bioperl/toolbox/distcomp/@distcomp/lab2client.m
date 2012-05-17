function lab2client(transferSeqNumber, labvarname, labidx)
; %#ok Undocumented
%lab2client Static wrapper around distcomp.interactivelab.lab2client.
%   This method can only be called on the labs, and it forwards the call to
%   the distcomp.interactivelab object.

%   Copyright 2006-2008 The MathWorks, Inc.

try
    labobj = distcomp.getInteractiveObject();
    labobj.lab2client(transferSeqNumber, labvarname, labidx);
catch err
    rethrow(err);
end
