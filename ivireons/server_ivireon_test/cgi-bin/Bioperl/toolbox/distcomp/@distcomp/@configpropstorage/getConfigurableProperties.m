function [props, types, isWritable] = getConfigurableProperties(className)
; %#ok Undocumented
%getConfigurableProperties Static method to get configurable properties.
%
%  Input is a class name or 'findResource', or 'JobManagerFindResource'.

%  Copyright 2007 The MathWorks, Inc.

distcomp.configpropstorage.pVerifyClassName(className);
store = distcomp.configpropstorage.pGetInstance();

% Strip of the initial distcomp. part when present.
className = regexprep(className, '^distcomp\.', '');

% Do not to query for the data types unless we are asked to return them, as this
% may trigger introspection.
props = store.pGetPropertyNames(className);
if nargout > 1
    types = store.pGetDataTypes(className);
end
if nargout > 2
    isWritable = store.pGetIsWritable(className);
end

