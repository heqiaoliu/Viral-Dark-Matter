function obj = configuration(name)
; %#ok Undocumented
%Returns a configuration object.

%   Copyright 2007 The MathWorks, Inc.

% Verify that name is a string.
if ~(ischar(name) && length(name) == size(name, 2))
    error('distcomp:configuration:InvalidName', ...
          'Configuration name must be a string.');
end

obj = distcomp.configuration;
% This will throw an error if there is no configuration with this name.
obj.pInitializeFromName(name);
