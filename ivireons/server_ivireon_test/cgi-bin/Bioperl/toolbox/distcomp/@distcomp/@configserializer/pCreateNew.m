function pCreateNew(obj, newName)
; %#ok Undocumented
%Private method that creates the specified configuration and bypasses the undo
%mechanism.

%   Copyright 2007 The MathWorks, Inc.

% This is a private method, so it should always be called with a valid, unused
% name.  We assert that this is the case:
if ismember(newName, {obj.Cache.configurations.Name})
    error('distcomp:configserializer:duplicateNames', ...
          'Proposed configuration name, %s, is already in use.', newName);
end

% Append the new configuration to the Cache:
obj.Cache.configurations(end + 1).Name = newName;
obj.Cache.configurations(end).Values = {};
obj.pFlushCache();
