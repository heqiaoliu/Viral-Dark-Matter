function propName = pTypeToPropertyName(obj, datatype)
; %#ok Undocumented    

%   Copyright 2007 The MathWorks, Inc.

index = obj.pTypeToPropertyIndex(datatype);
propName = obj.PropertyInfo(index).PropertyName;
