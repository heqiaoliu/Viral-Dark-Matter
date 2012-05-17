function names = pGetPropertyNames(obj, classNameOrFunctionName)
;%#ok Undocumented
%Return names of configurable properties.
%   props = pGetPropertyNames(obj, classNameOrFunctionName)
%   The value is returned as a cell string array.

% Copyright 2007 The MathWorks, Inc.

distcomp.configpropstorage.pVerifyClassName(classNameOrFunctionName);
try
    classInfo = obj.PropertyInfo.(classNameOrFunctionName);
    names = classInfo.PropertyNames;
catch
    % We don't have any information about this class.
    names = {};
end
