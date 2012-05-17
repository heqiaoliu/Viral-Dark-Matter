function datatypes = pGetDataTypes(obj, classNameOrFunctionName)
;%#ok Undocumented
%Return data types of configurable properties.
%   datatypes = pGetDataTypes(obj, classNameOrFunctionName)
%   The value is returned as a cell string array.

% Copyright 2007 The MathWorks, Inc.

distcomp.configpropstorage.pVerifyClassName(classNameOrFunctionName);
% First check whether we have any information about configurable properties for
% this class/function.
try
    classInfo = obj.PropertyInfo.(classNameOrFunctionName);
catch
    % We don't have any information about this class.
    datatypes = {};
    return;
end

if isempty(classInfo.DataTypes) && ~isempty(classInfo.PropertyNames)
    % Don't have any cached information, so collect the data type information.
    obj.PropertyInfo.(classNameOrFunctionName).DataTypes = ...
        distcomp.configpropstorage.pGetDataTypeInformation(classNameOrFunctionName, ...
                                                      classInfo.PropertyNames);
end

datatypes = obj.PropertyInfo.(classNameOrFunctionName).DataTypes;
