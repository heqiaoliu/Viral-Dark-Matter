function iswritable = getIsWritable(obj, name)
; %#ok Undocumented
% Gets the isReadWrite state of the specified property.

%   Copyright 2007 The MathWorks, Inc.

index = obj.pNameToIndex(name);
iswritable = obj.IsPropWritable(index);

