function constructor = getSchedulerUDDConstructor(name)
; %#ok Undocumented

%   Copyright 2006-2009 The MathWorks, Inc.

%   $Revision: 1.1.6.3 $  $Date: 2009/04/15 22:57:36 $

switch name
    case 'jobmanager'
        constructor = @distcomp.jobmanager;
    case 'lsf'
        constructor = @distcomp.lsfscheduler;        
    case 'pbspro'
        constructor = @distcomp.pbsproscheduler;
    case 'torque'
        constructor = @distcomp.torquescheduler;
    case 'hpcserver'
        constructor = @distcomp.ccsscheduler;
    case 'mpiexec'
        constructor = @distcomp.mpiexec;
    case 'generic'
        constructor = @distcomp.genericscheduler;
    case 'worker'
        constructor = @distcomp.worker;
    case 'local'
        constructor = @distcomp.localscheduler;    
    case 'runner'
        constructor = @distcomp.taskrunner;
    otherwise
        error('distcomp:scheduler:UnknownScheduler', 'Unable to supply constructor for scheduler %s. This is an unknown type', name);
end