function value = getValue(obj, name)
; %#ok Undocumented
% Gets the value of the specified property.

%   Copyright 2007 The MathWorks, Inc.

index = obj.pNameToIndex(name);
value = obj.pSafeGet(index);
value = value{1};
