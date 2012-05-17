function pInitializeFromName(obj, name)
; %#ok Undocumented
%Initialize a configuration by loading the information associated with the name.

%   Copyright 2007 The MathWorks, Inc.

% This will throw an error if there is no such configuration, except in the case
% of the 'local' configuration.
allValues = distcomp.configserializer.load(name);
obj.ActualName = name;

if isempty(allValues) && strcmp(name, 'local')
    % It's acceptable when the 'local' configuration does not fully exist on disk,
    % but then we must save it to disk.
    type = 'local';
else 
    type = obj.pGetTypeFromStruct(allValues, name);
end
% Create the sections of the configuration from its type.
% This will not throw an error, even if the type is invalid.
obj.pConstructFromClassTypes(type);

if ~isempty(allValues)
    % We have values to read from disk.
    obj.load();
else
    % We created a configuration out of thin air, so commit it to disk.
    obj.save();
end



