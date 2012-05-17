function pRemoveOldJobs(obj, sched)
; %#ok Undocumented
%Remove old jobs that are either finished or failed.
%   Also warn about jobs that are in the scheduler's queue.

%   Copyright 2006-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.4 $  $Date: 2010/02/25 08:01:20 $


[~, undoc] = pctconfig();
if undoc.preservejobs
    return;
end

jobs = sched.findJob('Tag', obj.Tag, 'UserName', obj.UserName);

if isempty(jobs) 
    return;
end
state = jobs.get({'State'});
old = strcmp(state, 'finished') | strcmp(state, 'failed');
running = strcmp(state, 'running');
pendingOrQueued = strcmp(state, 'pending') | strcmp(state, 'queued');

type = obj.CurrentInteractiveType;
if any(old)
    fprintf(['Destroying %d pre-existing parallel job(s) created by %s that '...
             'were in the \nfinished or failed state.\n\n'], ...
            nnz(old), type);
    jobs(old).destroy;
end
if any(running) || any(pendingOrQueued)
    cleanupCmd = '';
    explain = '';
    switch type        
        case 'pmode'
            if ~isempty(sched.Configuration)
                cleanupCmd = sprintf('use   ''pmode cleanup %s''   ', sched.Configuration);
            end
        case 'matlabpool'
            if ~isempty(sched.Configuration)
                cleanupCmd = sprintf('use   ''matlabpool close force %s''    or ', sched.Configuration);
            end
            cleanupCmd = sprintf(['%screate a configuration for the %s object and use   ', ...
                '''matlabpool close force <configurationName>''   '],...
                cleanupCmd, class(sched));
    end
    explain = sprintf(['You can %s to remove ' ...
                       'all jobs created by %s.'], cleanupCmd, type);

    if any(running) 
        if any(pendingOrQueued)
            warning('distcomp:interactive:JobsExist', ...
        ['Found %d pre-existing parallel job(s) created by %s that are '...
        'running,\nand %d parallel job(s) that are pending or queued.\n%s'], ...
                    nnz(running), type, nnz(pendingOrQueued), explain);
        else
            warning('distcomp:interactive:JobsExist', ...
        ['Found %d pre-existing parallel job(s) created by %s that are '...
        'running.\n%s'], ...
                    nnz(running), type, explain);
        end
    else 
            warning('distcomp:interactive:JobsExist', ...
        ['Found %d pre-existing parallel job(s) created by %s that are\n'...
        'pending or queued.\n%s'], ...
                    nnz(pendingOrQueued), type, explain);
    end        
end
