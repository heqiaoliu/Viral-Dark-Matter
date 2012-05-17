function enumValues = getEnumValues(datatype)
; %#ok Undocumented    
% Returns all the enum values of the data type, empty if the data type is not an
% enum.

%   Copyright 2007 The MathWorks, Inc.

obj = distcomp.typechecker.pGetInstance();
index = obj.pTypeToPropertyIndex(datatype);
enumValues = obj.PropertyInfo(index).EnumValues;
