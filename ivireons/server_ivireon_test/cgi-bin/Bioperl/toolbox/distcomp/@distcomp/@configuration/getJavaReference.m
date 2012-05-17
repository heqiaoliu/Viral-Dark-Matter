function obj = getJavaReference(name)
; %#ok Undocumented
%Returns a java interface to a configuration object.

%   Copyright 2007 The MathWorks, Inc.

% Verify that name is a string.
if ~(ischar(name) && length(name) == size(name, 2))
    error('distcomp:configuration:InvalidName', ...
          'Configuration name must be a string.');
end

conf = distcomp.configuration;
% This will throw an error if there is no configuration with this name.
conf.pInitializeFromName(name);
obj = java(conf);
obj.acquireReference;
    
