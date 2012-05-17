function pInstantiatePool(job, ~, ~, ~, args) 
; %#ok Undocumented
%pInstantiatePool 
%
%  pInstantiatePool(JOB, TASK)

% Copyright 2008-2009 The MathWorks, Inc.

% $Revision: 1.1.6.3 $    $Date: 2009/03/05 18:46:37 $

% We need to decide what sort of matlabpool job we are. There are
% interactive and batch matlabpool jobs. If we are interactive then all
% labs will be connecting back to the client - whos socket address will be
% provided in the input args to the task. If we are batch then lab 1 needs
% to become the client and all the rest need to communicate back to them


if job.pIsInteractivePool
    interactiveObject = distcomp.interactivelab;
    job.IsPoolTask = true;
    obj = distcomp.pGetInteractiveObject('set', interactiveObject);
    try
        mpiSettings( 'DeadlockDetection', 'on' );
        obj.connectToClient(args{:});
    catch err
        dctSchedulerMessage(1, 'Error message from pInstantiatePool: %s', err.message);
        throw(distcomp.ReportableException(err));
    end
else
    % Starting the MatlabPool client and labs
    leadingTaskNum = 1;
    if labindex == 1
        interactiveObject = distcomp.matlabpoolclient;
        job.IsPoolTask = false;
    else
        interactiveObject = distcomp.matlabpoollab;
        job.IsPoolTask = true;
    end
    obj = distcomp.pGetInteractiveObject('set', interactiveObject);
    obj.start(leadingTaskNum);
end