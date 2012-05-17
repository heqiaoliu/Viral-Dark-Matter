function postserialize(hThis,olddata) %#ok
%POSTSERIALIZE Restore object after serialization

%   Copyright 2006 The MathWorks, Inc.

% Set the "HandleVisibility" property of the created children back to "off"
hChil = hThis.getCreatedChildren;
set(hChil,'HandleVisibility','off');