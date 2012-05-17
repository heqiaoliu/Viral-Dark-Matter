function setJavaValue(obj, name, value)
; %#ok Undocumented
% Sets the value of the specified property from a Java data type.

%   Copyright 2007-2008 The MathWorks, Inc.

index = obj.pNameToIndex(name);
if ~obj.IsPropWritable(index)
    error('distcomp:configuration:invalidValue', ...
          'Cannot assign value to the read-only property %s.', ...
          name);
end    

if ~obj.IsPropEnabled(index)
    dctSchedulerMessage(1,'Cannot assign value to disabled property %s.', name);
    error('distcomp:configuration:disabledProperty', ...
          'Cannot assign value to disabled property %s.', name);
end

orgStr = value;

% Rewrite some of the data types for Java.  The data types that we don't rewrite
% are handled automatically by MATLAB, such as strings and string arrays.
switch obj.Types{index}
  case 'MATLAB callback'
    value = distcomp.typechecker.string2callback(value);
  case 'MATLAB array'
    if ischar(value) && ~isempty(regexp(value, '^\s*struct\s*(.*)', 'once' ))
        % This is a struct that is encoded as a string.
        try
            value = eval(value);
        catch err
            dctSchedulerMessage(1, ['Failed to set property %s ', ...
                                'to %s due to the error %s.'], name, orgStr, err.message);
            rethrow(err);
        end
        if ~(isstruct(value) && length(value) == 1 && isfield(value, 'pc') ...
             && isfield(value, 'unix') && length(fieldnames(value)) == 2)
            dctSchedulerMessage(1, 'Invalid struct for property %s: %s', name, orgStr);
            error('distcomp:configuration:invalidValue', ...
                  'Value must be a single struct with the fields ''pc'' and ''unix''.');
        end
    end
  case 'double'
    value = double(value);
  case 'boolean'
    value = logical(value);
  case 'string'
    value = char(value);
  case 'string vector'
    value = cell(value);
end
if ~distcomp.typechecker.isCorrectType(obj.Types{index}, value)
    dctSchedulerMessage(1, 'Invalid value specified for %s.%s.', ...
        obj.SectionName, name);
    error('distcomp:configuration:invalidValue', ...
          'Invalid value specified for the %s property.', ...
          name);
end


obj.PropValue{index} = value;
