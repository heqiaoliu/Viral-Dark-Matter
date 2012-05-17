function setFromEnabledStruct(obj, val)
; %#ok Undocumented
% Sets all properties in this object to be as stored in the input struct.  Any
% writable property not found in the input struct is disabled and set to its
% default value.  Does not throw any errors.

%   Copyright 2007-2008 The MathWorks, Inc.

n = length(obj.Names);
for i = 1:n
    currName = obj.Names{i};
    % By default, we disable properties and set them to default values,
    % but we don't want information on disk override the isEnabled
    % state of any read-only properties.
    if obj.IsPropWritable(i)
        obj.IsPropEnabled(i) = false;
        obj.PropValue{i} = distcomp.typechecker.getDefaultValue(obj.Types{i});
    end
    % Use the property value stored in the struct, if any.
    try
        currValue = val.(currName);
    catch err %#ok<NASGU>
        % There was no information about currName.
        continue;
    end

    if distcomp.typechecker.isCorrectType(obj.Types{i}, currValue)
        obj.PropValue{i} = currValue;
        if obj.IsPropWritable(i)
            obj.IsPropEnabled(i) = true;
        end
    else
        warning('distcomp:configuration:incorrectType', ...
            'Ignoring invalid value of the %s.%s property.', ...
            obj.SectionName, obj.Names{i});
    end
end
