function setIsEnabled(obj, name, isenabled)
; %#ok Undocumented
% Sets the isEnabled state of the specified property.

%   Copyright 2007 The MathWorks, Inc.

if ~(isscalar(isenabled) && islogical(isenabled))
    error('distcomp:configuration:InvalidEnabledState', ...
          'The enabled state must be a scalar logicar.');
end
index = obj.pNameToIndex(name);
if ~obj.IsPropWritable(index)
    error('distcomp:configuration:ReadOnlyProperty', ...
        'Cannot modify the isEnabled state of the read-only %s property.', name);
end
obj.IsPropEnabled(index) = isenabled;

if ~isenabled
    obj.PropValue{index} =  distcomp.typechecker.getDefaultValue(obj.Types{index});
end
