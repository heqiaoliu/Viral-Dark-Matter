function setValue(obj, name, value)
; %#ok Undocumented
% Sets the value of the specified property.

%   Copyright 2007-2008 The MathWorks, Inc.

index = obj.pNameToIndex(name);

if ~distcomp.typechecker.isCorrectType(obj.Types{index}, value)
    error('distcomp:configuration:invalidValue', ...
          'Invalid value specified for the %s property.', ...
          name);
end

if ~obj.IsPropEnabled(index)
    error('distcomp:configuration:disabledProperty', ...
          'Cannot assign value to disabled property %s.', name);
end

% We don't allow callbacks to contain values that we can't convert to string.
if ~isempty(value) &&  strcmp(obj.Types{index}, 'MATLAB callback')
    try 
        distcomp.typechecker.callback2string(value);
    catch err
        ex = MException('distcomp:configuration:invalidValue', ...
                        'Invalid callback specified for the %s property.', ...
                        name);
        ex = ex.addCause(err);
        throw(ex);
    end
end

obj.PropValue{index} = value;
