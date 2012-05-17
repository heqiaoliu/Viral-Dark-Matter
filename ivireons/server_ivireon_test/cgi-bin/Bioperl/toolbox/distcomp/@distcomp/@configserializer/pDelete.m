function pDelete(obj, configName)
; %#ok Undocumented
%Private method that deletes the specified configuration and bypasses the undo
%mechanism.

%   Copyright 2007 The MathWorks, Inc.

% pGetID throws an error if configName is invalid.
ID = obj.pGetID(configName);
obj.Cache.configurations(ID) = [];

% The user might have deleted the local configuration, but we handle that when
% we flush the cache.
obj.pFlushCache();
