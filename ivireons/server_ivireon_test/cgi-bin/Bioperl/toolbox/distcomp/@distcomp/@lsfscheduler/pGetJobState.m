function state = pGetJobState(scheduler, job, state) %#ok<INUSL>
; %#ok Undocumented
%pGetJobState - deferred call to ask the scheduler for state information
%
%  STATE = pGetJobState(SCHEDULER, JOB, STATE)

%  Copyright 2005-2010 The MathWorks, Inc.

%  $Revision: 1.1.10.6 $    $Date: 2010/03/01 05:20:15 $

% Only ask the scheduler what the job state is if it is queued or running
if strcmp(state, 'queued') || strcmp(state, 'running')
    % Get the information about the actual scheduler used
    data = job.pGetJobSchedulerData;
    if isempty(data)
        return
    end
    % Is the job actually an LSF job?
    if ~strcmp(data.type, 'lsf')
        return
    end
    % Finally let's get the actual jobID
    jobID = data.lsfID;
    % Ask LSF about this job
    [FAILED, out] = dctSystem(sprintf('bjobs %d', jobID));
    if FAILED
        warning('distcomp:lsfscheduler:UnableToFindService', ...
            'Error executing the LSF script command ''bjobs''. The reason given is \n %s', out);
        return
    end
    % How many PEND, PSUSP, USUSP, SSUSP, WAIT
    numPending = numel(regexp(out, 'PEND|PSUSP|USUSP|SSUSP|WAIT'));
    % How many RUN strings - UNKWN started running and then comms was lost
    % with the sbatchd process.
    numRunning = numel(regexp(out, 'RUN|UNKWN'));
    % How many DONE, EXIT, ZOMBI strings
    numFailed = numel(regexp(out, 'EXIT|ZOMBI'));
    % Now deal with the logic surrounding these
    % Any running indicates that the job is running
    if numRunning > 0
        state = 'running';
        return
    end
    % We know numRunning == 0 so if there are some still pending then the
    % job must be queued again, even if there are some finished
    if numPending > 0
        state = 'queued';
        return
    end
    % Deal with any tasks that have failed - ensure that we write the
    % failed string to the task
    if numFailed > 0
        % Set this job to be failed
        state = 'failed';
        job.pSetState(state);
        % Get the LSF task ID of the failed tasks
        failedLsfIndex = iParseBjobsOutputForExit(out, numFailed);
        % Find the correct tasks with those ID's
        tasks = job.Tasks;
        failedTasks = handle(-ones(numel(failedLsfIndex), 1));
        failedTasksIndex = 0;
        for i = 1:numel(tasks)
            if ismember(tasks(i).ID, failedLsfIndex)
                failedTasksIndex = failedTasksIndex + 1;
                failedTasks(failedTasksIndex) = tasks(i);
            end
        end
        % For each failed task write the failed state correctly
        for i = 1:failedTasksIndex
            thisTask = failedTasks(i);
            if ~strcmp(thisTask.State, 'finished')
                thisTask.pSetState('failed');
            end
        end
        return
    end
    % numPending and numRunning are 0, so there could be some finished or
    % there could ne none finished. If none, this is because the job has
    % fallen off the recent LSF list. In either case it is likely that all
    % parts of the job are finished. However, lets quickly check that all
    % tasks are finished if numFinished == 0. If all tasks have actually
    % finished then mark the job as finished
    state = job.pGetStateFromTasks;
    if strcmp(state, 'finished')
        job.pSetState(state);
    end
end

function iFailedLsfIndex = iParseBjobsOutputForExit(out, numFailed)
% We are expecting out to look something like this
%
% JOBID   USER    STAT  QUEUE      FROM_HOST   EXEC_HOST   JOB_NAME   SUBMIT_TIME
% 7005    jlmarti EXIT  normal     uk-martinj-    -        Job2[1]    Jul 26 11:16
% 7005    jlmarti EXIT  normal     uk-martinj-    -        Job2[2]    Jul 26 11:16
% 7005    jlmarti EXIT  normal     uk-martinj-    -        Job2[3]    Jul 26 11:16
% 7005    jlmarti EXIT  normal     uk-martinj-    -        Job2[4]    Jul 26 11:16

% Convert the output to a cell array of lines
lout = regexp(out, '.*?\n', 'match');
% Remove the header line 
lout(1) = [];
% Loop over the lines looking for EXIT or ZOMBI
iFailedLsfIndex = zeros(1, numFailed);
iFailedCount = 1;
for i = 1:numel(lout)
    thisLine = lout{i};
    if ~isempty(regexp(thisLine, 'EXIT|ZOMBI', 'once'))
        % Split into whitespace delimited cells
        thisLineCell = regexp(thisLine, '[^\s]+', 'match');
        jobIndexCellStr = {};
        % Need to check that thisLineCell{7} has [] with a number inside
        if numel(thisLineCell) >= 7
            jobIndexCellStr = regexp(thisLineCell{7}, '\[([0-9]+)\]', 'tokens', 'once');
        end
        % Did our first attempt to get the jobIndexCellStr work?
        if isempty(jobIndexCellStr)
            jobIndexCellStr = regexp(thisLine, '\[([0-9]+)\]', 'tokens', 'once');            
        end
        try
            iFailedLsfIndex(iFailedCount) = str2double(jobIndexCellStr{1});
            iFailedCount = iFailedCount + 1;
        catch err %#ok<NASGU>
            % Remove this one from the possible list since we failed to get
            % an LSF job array index
            iFailedLsfIndex(iFailedCount) = [];
        end
    end
end
