function y = pctdemo_task_tutorial_network_traffic(p)
%PCTDEMO_TASK_TUTORIAL_NETWORK_TRAFFIC Calculate x.^p.
%   y = pctdemo_task_tutorial_network_traffic(p) uses getCurrentJob to obtain 
%   the JobData property of the current job.  The function then returns 
%   the p-th power of the vector found in the JobData property.
    
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:59 $
    
    job = getCurrentJob();
    if isempty(job)
        % We are not running on a worker, so we do not have any JobData to 
        % work on.
        y = [];
        return;
    end
    
    x = get(job, 'JobData');
    y = x.^p;
end % End of pctdemo_task_tutorial_network_traffic.
