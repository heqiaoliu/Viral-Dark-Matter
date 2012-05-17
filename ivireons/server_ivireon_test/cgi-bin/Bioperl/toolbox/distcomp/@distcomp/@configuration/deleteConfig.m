function deleteConfig(name)
; %#ok Undocumented
%Deletes the configuration with the specified name.

%   Copyright 2007 The MathWorks, Inc.

% This will throw an error if the name is invalid, or if no such configuration
% exists.
distcomp.configserializer.deleteConfig(name);

