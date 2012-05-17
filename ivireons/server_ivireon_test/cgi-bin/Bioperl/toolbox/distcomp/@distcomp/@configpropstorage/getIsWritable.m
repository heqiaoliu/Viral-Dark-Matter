function iswritable = getIsWritable(obj, classNameOrFunctionName)
;%#ok Undocumented
%Return writable/not writable status of configurable properties.
%   iswritable = getIsWritable(obj, classNameOrFunctionName)
%   The value is returned as a vector of logicals

% Copyright 2007 The MathWorks, Inc.

distcomp.configpropstorage.pVerifyClassName(classNameOrFunctionName);
try
    iswritable = obj.PropertyInfo.(classNameOrFunctionName).IsWritable;
catch
    % We don't have any information about this class.
    iswritable = logical([]);
end
