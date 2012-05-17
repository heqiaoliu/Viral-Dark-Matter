function name = createNew(type)
; %#ok Undocumented
%createnew Static method to create a new configuration for a specific
%scheduler type.
%

%  Copyright 2007-2008 The MathWorks, Inc.

obj = distcomp.configuration;

% Return the return value and just use the error checking.  This will throw an
% error if the type is invalid.
obj.pMapFRTypeToSchedClassType(type);

% Let the names be jobmanagerconfig1, localconfig1, etc.
% The serializer will add the numeric suffix.
proposedName = sprintf('%sconfig', type);
try
    obj.ActualName = distcomp.configserializer.createNew(proposedName);
    obj.pConstructFromClassTypes(type);
    obj.save();
catch err
    try
        distcomp.configserializer.deleteConfig(obj.ActualName);
    catch
    end
    rethrow(err);
end
name = obj.ActualName;
