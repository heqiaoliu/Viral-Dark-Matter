function pSave(obj, configName, values)
; %#ok Undocumented
%Private method that saves the specified configuration values and bypasses the
%undo mechanism.

%   Copyright 2007 The MathWorks, Inc.

ID = obj.pGetID(configName);
obj.Cache.configurations(ID).Values = values;
obj.pFlushCache();
