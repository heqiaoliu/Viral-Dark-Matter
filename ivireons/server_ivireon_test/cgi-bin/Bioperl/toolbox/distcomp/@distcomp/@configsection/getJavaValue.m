function value = getJavaValue(obj, name)
; %#ok Undocumented
% Gets the value of the specified property as a Java data type.

%   Copyright 2007 The MathWorks, Inc.

index = obj.pNameToIndex(name);
value = obj.pSafeGet(index);
%  Convert back from a cell array.
value = value{1};

% Translate all the empty strings and string arrays correctly to Java.
% Otherwise, these would appear as null objects in Java.
if isempty(value) 
    if ischar(value)
        value = java.lang.String('');
        return;
    elseif strcmp(obj.Types{index}, 'string vector')
        % It's not so easy to construct an empty String[] from Matlab, so we settle for
        % an array of length 1 that contains a null string.  Let the Java side
        % handle the rest.
        value = javaArray('java.lang.String', 1);
        return;
    end
end

% Rewrite some of the data types for Java.  The data types that we don't rewrite
% are handled automatically by MATLAB, such as string arrays. Because
% MATLAB automatically converts single element chars to Character, we must
% also explicitely convert callbacks, non-struct MATLAB arrays, and strings 
% to String.
switch obj.Types{index}
  case 'MATLAB callback'
    value = java.lang.String(distcomp.typechecker.callback2string(value));
  case 'MATLAB array'
    if isstruct(value)
        value = java.lang.String(sprintf('struct(''pc'', ''%s'', ''unix'', ''%s'')', value.pc, value.unix));
    else
        value = java.lang.String(value);
    end
  case 'boolean'
    value = java.lang.Boolean(value);
  case 'double'
    value = java.lang.Double(value);
  case 'string'
    value = java.lang.String(value);    
end

