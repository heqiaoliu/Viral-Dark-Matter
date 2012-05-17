function isenabled = getIsEnabled(obj, name)
; %#ok Undocumented
% Gets the isEnabled state of the specified property.

%   Copyright 2007 The MathWorks, Inc.

index = obj.pNameToIndex(name);
isenabled = obj.IsPropEnabled(index);

