function olddata = preserialize(hThis)
%PRESERIALIZE Prepare object for serialization

%   Copyright 2006 The MathWorks, Inc.

% Set the "HandleVisibility" property of the created children to "on".
olddata = [];
hChil = hThis.getCreatedChildren;
set(hChil,'HandleVisibility','on');