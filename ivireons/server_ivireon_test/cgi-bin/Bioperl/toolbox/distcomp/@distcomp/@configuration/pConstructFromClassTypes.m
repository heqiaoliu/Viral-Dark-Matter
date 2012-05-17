function pConstructFromClassTypes(obj, typeArg)
; %#ok Undocumented
%pConstructFromClassTypes Static method to create the configuration sections.
%
%  Input is a value for the 'type' argument to findResource.

%  Copyright 2007 The MathWorks, Inc.

% This method does not throw an error on an invalid type argument.  Instead, it
% allows us to construct the object so that the UI can display the broken
% configuration.
try
    schedType = obj.pMapFRTypeToSchedClassType(typeArg);
catch
    warning('distcomp:configuration:ResettingType', ...
            ['Failed to recognized the scheduler type ''%s'' in the ', ...
            'configuration ''%s''.\n', ...
             'Resetting the configuration to be for the local scheduler.'], ...
            typeArg, obj.ActualName);
    typeArg = 'local';
    schedType = 'localscheduler';
end

% Map typeArg to arguments to getConfigurableProperties.
if strcmp(typeArg, 'jobmanager')
    findResourceType = 'JobManagerFindResource';
    job = 'job';
    pjob = 'paralleljob';
    task = 'task';
else
    findResourceType = 'findResource';
    job = 'simplejob';
    pjob = 'simpleparalleljob';
    task = 'simpletask';
end

% Construct the findResource section that is appropriate for this scheduler.
[props, types, isRW] = distcomp.configpropstorage.getConfigurableProperties(findResourceType);
obj.findResource = distcomp.configsection('findResource', props, types, isRW);
% Set the correct, publicly visible scheduler type to findResource.
obj.findResource.setValue('Type', typeArg);

[props, types, isRW] = distcomp.configpropstorage.getConfigurableProperties(schedType);
obj.scheduler = distcomp.configsection('scheduler', props, types, isRW);

[props, types, isRW] = distcomp.configpropstorage.getConfigurableProperties(job);
obj.job = distcomp.configsection('job', props, types, isRW);

[props, types, isRW] = distcomp.configpropstorage.getConfigurableProperties(pjob);
obj.paralleljob = distcomp.configsection('paralleljob', props, types, isRW);

[props, types, isRW] = distcomp.configpropstorage.getConfigurableProperties(task);
obj.task = distcomp.configsection('task', props, types, isRW);
