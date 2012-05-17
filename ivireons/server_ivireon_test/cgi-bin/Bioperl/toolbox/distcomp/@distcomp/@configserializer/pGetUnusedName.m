function configName = pGetUnusedName(obj, proposedName)
; %#ok Undocumented
% pGetUnusedNameAndID Returns a name which is not in use.

%   Copyright 2007 The MathWorks, Inc.

if ~(ischar(proposedName) && length(proposedName) == size(proposedName, 2) && ~isempty(proposedName))
    error('distcomp:configuration:InvalidName', ...
          'Configuration name must be a non-empty string.');
end

names = {obj.Cache.configurations.Name};

for i = 1:length(names) + 1
    configName = sprintf('%s%d', proposedName, i);
    if ~any(strcmp(configName, names))
        break;
    end
end
