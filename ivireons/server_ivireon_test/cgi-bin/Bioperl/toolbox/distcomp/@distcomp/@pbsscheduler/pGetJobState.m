function state = pGetJobState( pbs, job, state ) %#ok<INUSL>
; %#ok Undocumented

% pGetJobState - ask PBS for job state information

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2007/11/09 19:50:58 $

% Only ask the scheduler what the job state is if it is queued or running
if strcmp(state, 'queued') || strcmp(state, 'running')

    % Get the information about the actual scheduler used
    data = job.pGetJobSchedulerData;
    if isempty(data) || ~strcmp( data.type, 'pbs' )
        return
    end

    % Finally let's get the actual jobIDs
    jobIDs = data.pbsJobIds;

    % Actually, for running/pending calculation, we don't care about the state
    % of the subjobs, so treat everything the same.
    [anyRunning, anyPending, FAILED] = iGetRunningPending( pbs, jobIDs );

    if FAILED
        % Already warned in iGetRunningPending
        return
    end
    
    % Now deal with the logic surrounding these
    % Any running indicates that the job is running
    if anyRunning
        state = 'running';
        return
    end

    % We know numRunning == 0 so if there are some still pending then the
    % job must be queued again, even if there are some finished
    if anyPending
        state = 'queued';
        return
    end

    % Ensure that all tasks have the right state
    if ~anyRunning && ~anyPending
        
        jobState = 'finished';
        
        stateFromTasks = job.pGetStateFromTasks;
        
        if strcmp( stateFromTasks, 'finished' )
            % Ok, we're good, the job will be set 'finished'
        else
            % Bad - there are no running or pending tasks, so let's overwrite any tasks
            % that aren't finished to 'failed', and then set the job to be failed.
            
            for ii=1:length( job.Tasks )
                if ~strcmp( job.Tasks( ii ).State, 'finished' )
                    % Tasks must be failed
                    job.Tasks( ii ).pSetState( 'failed' );
                    
                    % Job must be failed too, by definition
                    jobState = 'failed';
                end
            end
        end
        job.pSetState( jobState );
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iGetRunningPending - return the number of jobs/tasks that are running or
% pending. Uses "qstat -f" on each job ID in turn. The cunning use of
% qselect doesn't work because you need multiple calls, and the state of a
% job can change in between those calls, so this method is more
% conservative, and ensures that it retrieves the state of each PBS job
% precisely once.
function [anyRun, anyPend, FAILED] = iGetRunningPending( pbs, jobIDs )

anyRun  = false;
anyPend = false;
FAILED  = 0;

for ii=1:length( jobIDs )
    cmdLine = sprintf( 'qstat -f "%s"', jobIDs{ii} );
    [FAILED, out] = pbs.pPbsSystem( cmdLine );
    
    if ~isempty( strfind( out, 'Unknown Job Id' ) )
        % Get here for a job that PBS has no knowledge of. 
        FAILED = 0;
        continue;
    end
    
    if FAILED
        % Some other problem with qstat -f
        warning( 'distcomp:pbsscheduler:UnableToQueryState', ...
                 'Error executing the PBS command ''%s''. The reason given is \n %s', ...
                 cmdLine, out );
        return
    end
    stateLine = regexp( out, 'job_state = [A-Z]', 'match', 'once' );
    if isempty( stateLine )
        warning( 'distcomp:pbsscheduler:FailedToParseQstat', ...
                 ['Couldn''t interpret job state from the output of qstat -f.\n', ...
                  'qstat returned:\n%s'], out );
    else
        stateLetter = stateLine(end);
        
        % Use the scheduler-specific state indicators to see if this particular
        % letter indicates running or pending.
        if ~isempty( strfind( pbs.StateIndicators{1}, stateLetter ) )
            anyRun  = true;
        elseif ~isempty( strfind( pbs.StateIndicators{2}, stateLetter ) )
            anyPend = true;
        end
    end
    
    if anyRun && anyPend
        % If we get here, we'll never get any further - so break out.
        break;
    end
end
