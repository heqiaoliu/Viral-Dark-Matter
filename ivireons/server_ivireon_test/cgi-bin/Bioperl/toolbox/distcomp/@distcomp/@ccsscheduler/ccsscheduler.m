function obj = ccsscheduler(proxyScheduler)
%CCSSCHEDULER concrete constructor for this class
%
%  OBJ = CCSSCHEDULER(OBJ)

%  Copyright 2006-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.7 $    $Date: 2010/04/21 21:13:56 $

% Don't go any further if we aren't running on a PC.
if ~ispc
    error('distcomp:ccsscheduler:IncorrectPlatform', 'The HPC Server scheduler is supported only on windows');
end

obj = distcomp.ccsscheduler;

set(obj, ...
    'Type', 'hpcserver', ...
    'Storage', handle(proxyScheduler.getStorageLocation), ...
    'HasSharedFilesystem', true);

% Let's test that we are able to create a link to the scheduler
if distcomp.HPCServerSchedulerConnection.testClientCompatibilityWithMicrosoftAPI
    clientAPIVersion = distcomp.HPCServerSchedulerConnection.getAPIVersion;
elseif distcomp.CCSSchedulerConnection.testClientCompatibilityWithMicrosoftAPI
    clientAPIVersion = distcomp.CCSSchedulerConnection.getAPIVersion;
else
    error('distcomp:ccsscheduler:UnableToContactService', ...
        'It appears that the HPC Server scheduler client utilities are not installed on this machine');
end

% Indicate that we have tested for Microsoft Client Utilities
obj.HaveTestedForMicrosoftClientUtilities = true;
% It is very important that the ClusterVersion is set prior to the 
% the SchedulerHostname.  
obj.ClusterVersion = clientAPIVersion;

% This class accepts configurations and uses the scheduler section.
sectionName = 'scheduler';
obj.pInitializeForConfigurations(sectionName);

% Use the same default environment variable that MS does to connect to a
% scheduler.
defaultSchedulerName = getenv('CCP_SCHEDULER');
if ~isempty(defaultSchedulerName)
    obj.SchedulerHostname = defaultSchedulerName;
end

% Indicate that we have finished initializing the object
obj.Initialized = true;