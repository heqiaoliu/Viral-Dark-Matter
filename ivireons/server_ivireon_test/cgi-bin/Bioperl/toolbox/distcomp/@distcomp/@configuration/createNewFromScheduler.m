function name = createNewFromScheduler(sched)
; %#ok Undocumented
%createNewFromScheduler Static method to create a new configuration from a scheduler object.
%

%  Copyright 2007-2009 The MathWorks, Inc.
    
% Make sure that we have a singleton that we can call class on.
if ~(isscalar(sched) && ishandle(sched))
    error('distcomp:configuration:InvalidSchedulerObject', ...
          'Input must be a single scheduler object.');
end
classtype = class(sched);
% Get the type argument to findResource, and validate the class type at the same
% time.
typeArg = distcomp.configuration.pMapSchedClassTypeToFRType(classtype);
try
    name = distcomp.configuration.createNew(typeArg);
    % Get the configuration object that corresponds to the name.
    obj = distcomp.configuration;
    obj.pInitializeFromName(name);
    % Now initialize the configuration using the scheduler object.
    props = distcomp.configpropstorage.getConfigurableProperties(classtype);
    vals = sched.pGetConfigurationValue(props);
    for i = 1:length(props)
        obj.scheduler.setIsEnabled(props{i}, true);
        obj.scheduler.setValue(props{i}, vals{i});
    end

    % The job manager also needs the Name and LookupURL to findResource.
    if isa(sched, 'distcomp.jobmanager')
        obj.findResource.setIsEnabled('LookupURL', true);
        % TODO: Ensure the correct value of base port.
        obj.findResource.setValue('LookupURL', sched.HostName);
        obj.findResource.setIsEnabled('Name', true);
        obj.findResource.setValue('Name', sched.Name);
    end
    % Save the resulting configuration.
    obj.save();
catch err
    try
        distcomp.configserializer.deleteConfig(obj.ActualName);
    catch
    end
    rethrow(err);
end

name = obj.ActualName;
