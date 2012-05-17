function type = pGetTypeFromStruct(obj, allValues, name) %#ok obj never used.
; %#ok Undocumented
%Figures out what the type of the configuration is based on the input struct.

% Create a temporary findResource section to figure out what type we should be.
[props, types, isW] = distcomp.configpropstorage.getConfigurableProperties('findResource');
tempSection = distcomp.configsection('findResource', props, types, isW);

try
    tempSection.setFromEnabledStruct(allValues.findResource);
    type = tempSection.getValue('Type');
catch
    % Configuration may have been empty, or invalid.  In either case, default to
    % local.
    warning('distcomp:configuration:LoadFailed', ...
            ['Could not read the type of the configuration ''%s''.\n', ...
             'Resetting its type to be ''local''.'], name);
    type = 'local';
end
