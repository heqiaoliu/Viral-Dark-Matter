function ID = pGetID(obj, configName)
; %#ok Undocumented
%Convert a configuration name into an ID.
%   The ID can be used as an index into ser.Cache.configurations.
%   Throws an error if the specified configuration does not exist.

%   Copyright 2007 The MathWorks, Inc.

% Verify that configName is a string.
if ~(ischar(configName) && length(configName) == size(configName, 2) && ~isempty(configName))
    error('distcomp:configuration:InvalidName', ...
          'Configuration name must be a non-empty string.');
end


allNames = {obj.Cache.configurations.Name};
ID = find(strcmp(allNames, configName));
if isempty(ID)
    error('distcomp:configuration:NoSuchConfiguration', ...
          'There is no configuration named ''%s''.', configName);
end

if length(ID) > 1
    warning('distcomp:configuration:DuplicateNames', ...
          'There are %d configurations named ''%s''.', ...
            length(ID), configName);
    ID = ID(1);
end
