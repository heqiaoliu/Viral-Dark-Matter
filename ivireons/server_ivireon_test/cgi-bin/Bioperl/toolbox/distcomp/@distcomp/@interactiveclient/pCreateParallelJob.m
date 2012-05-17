function pCreateParallelJob(obj, sched, desiredNumlabs, sockAddr)
; %#ok Undocumented
%pCreateParallelJob Create a parallel job to start an interactive session and store in obj.ParallelJob.
%   The parallel job will connect back to the specified sockAddr
%   and is tagged with obj.Tag.
%   Use desiredNumlabs if it is non-empty.

%   Copyright 2006-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.9 $  $Date: 2010/02/25 08:01:19 $

% Create parallel job to attach to this client - note that configuration is
% first in the list so that what follows overrides it's values
if ~isempty(desiredNumlabs)
    numWorkersArgs = struct('MaximumNumberOfWorkers', desiredNumlabs, ...
                            'MinimumNumberOfWorkers', desiredNumlabs);
else
    numWorkersArgs = struct;
end
pjob = sched.createMatlabPoolJob(...
    'Configuration', sched.Configuration, ...
    'Tag', obj.Tag, ...
    numWorkersArgs);
    
pjob.pSetInteractiveJob(true);
obj.ParallelJob = pjob;


% The task to run will connect back to the SocketAddress below
pjob.createTask(@distcomp.nop, 0, ...
                {sockAddr}, ...
                'Configuration', sched.Configuration);
