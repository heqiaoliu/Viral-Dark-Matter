function value = getDefaultValue(datatype)
; %#ok Undocumented
% Returns the default value for the specified data type.

%   Copyright 2007 The MathWorks, Inc.

obj = distcomp.typechecker.pGetInstance(); 
prop = obj.pTypeToPropertyName(datatype);
% The property values in obj are always the default values for those properties.
value = obj.(prop);
