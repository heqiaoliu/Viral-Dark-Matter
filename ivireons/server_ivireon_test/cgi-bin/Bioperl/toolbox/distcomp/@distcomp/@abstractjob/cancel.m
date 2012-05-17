function cancel(jobs, opt_user_message)
; %#ok Undocumented
%cancel  Cancel a job
%
% cancel(j) stops the job object, j, that has been submitted to a scheduler.
% The job's State property is set to finished, and any results that have
% been computed for the job object are saved and may be accessed normally. 
%
% cancel(j, 'message') cancels the job with an additional user-specified
% message. This message will be added to the default cancellation message.
%
% If the job is running in a scheduler attempts will be made through the
% scheduler to contact those workers and stop them. If the scheduler does
% not support this level of functionallity then the tasks will continue to
% be evaluated.
%
% Example:
%     jm = findResource('scheduler', 'type', 'lsf');
%     j  = createJob(jm);
%     t  = createTask(@rand, 1, {1});
%     submit(j);
%     cancel(j);
%
% See also distcomp.job/submit, distcomp.job/cancel

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.6 $    $Date: 2008/10/02 18:40:25 $ 

currentUser = char(java.lang.System.getProperty('user.name'));
currentHost = char(java.net.InetAddress.getLocalHost.getCanonicalHostName);
message = sprintf('Job cancelled by user: %s on machine: %s', currentUser, currentHost);
if nargin > 1    
    message = sprintf( '%s\nwith message: %s', message, opt_user_message );
end
for i = 1:numel(jobs)
    thisJob = jobs(i);
    allTasks = thisJob.Tasks;
    try        
        % Get a serializer for the tasks - assume this is the same for all
        % tasks in a job.
        serializer = thisJob.Serializer;
        try
            jobState = serializer.getFields(thisJob, {'state'});
            % Only cancel the tasks if there are some
            if numel(allTasks) > 0
                taskState = serializer.getFields(allTasks, {'state'});
                tasksNotFinished = ~strcmp(taskState, 'finished');
                DO_CANCEL = any(tasksNotFinished);
            else
                tasksNotFinished = [];
                DO_CANCEL = ~strcmp(jobState, 'finished');
            end
        catch err
            % Likely cause of error here is corrupt data on disk
            newErr = MException('distcomp:job:CorruptData', 'Data corruption in storage');
            newErr = newErr.addCause(err);
            throw(newErr);
        end
        if DO_CANCEL
            % We can cancel this job if it is still pending
            OK_TO_CANCEL = distcomp.jobStateIsAt(jobState, 'pending');
            % Ask the scheduler if it thinks we can cancel this job
            if ~OK_TO_CANCEL
                try
                    scheduler = thisJob.pGetManager;
                    OK_TO_CANCEL = scheduler.pCancelJob(thisJob);
                catch err
                    warning('distcomp:job:SchedulerError', ...
                        'Unable to cancel job because the scheduler threw an error. Nested error:\n%s', err.message);
                    OK_TO_CANCEL = false;
                end
            end
            % If the scheduler indicates that it did not manage to cancel the 
            % job then we shouldn't write anything to the job
            if OK_TO_CANCEL
                % Now write the cancel message to the tasks
                serializer.putFields(allTasks(tasksNotFinished), ...
                    {'erroridentifier', 'errormessage', 'finishtime' 'state'}, ...
                    {'distcomp:task:Cancelled', message, char(java.util.Date) 'finished'});
                % And to this job
                serializer.putFields(thisJob, ...
                    {'finishtime' 'state'}, ...
                    {char(java.util.Date) 'finished'});
            end
        end
    catch err
        % TODO
        rethrow(err)
    end
end