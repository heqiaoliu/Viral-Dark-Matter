function obj = taskrunner(proxyScheduler)
; %#ok Undocumented
%LSFSCHEDULER concrete constructor for this class
%
%  OBJ = TASKRUNNER(OBJ)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:39:46 $


obj = distcomp.taskrunner;


set(obj, ...
    'Storage', handle(proxyScheduler.getStorageLocation), ...
    'HasSharedFilesystem', true, ...
    'DependencyDirectory', [tempname, 'tr', num2str(system_dependent('getpid'))]);