function obj = genericscheduler(proxyScheduler)
; %#ok Undocumented
%genericscheduler concrete constructor for this class
%
%  OBJ = genericscheduler(PROXY)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.4 $    $Date: 2007/06/18 22:12:49 $


obj = distcomp.genericscheduler;

set(obj, ...
    'Type', char(proxyScheduler.getSchedulerName), ...
    'Storage', handle(proxyScheduler.getStorageLocation), ...
    'HasSharedFilesystem', true);

% This class accepts configurations and uses the scheduler section.
sectionName = 'scheduler';
obj.pInitializeForConfigurations(sectionName);
