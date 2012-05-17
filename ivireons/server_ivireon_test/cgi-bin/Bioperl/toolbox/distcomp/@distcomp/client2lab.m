function client2lab(transferSeqNumber, labidx, labvarname)
; %#ok Undocumented
%client2lab Static wrapper around distcomp.interactivelab.client2lab.
%   This method can only be called on the labs, and it forwards the call to
%   the distcomp.interactivelab object.

%   Copyright 2006 The MathWorks, Inc.

labobj = distcomp.getInteractiveObject();
labobj.client2lab(transferSeqNumber, labidx, labvarname);


