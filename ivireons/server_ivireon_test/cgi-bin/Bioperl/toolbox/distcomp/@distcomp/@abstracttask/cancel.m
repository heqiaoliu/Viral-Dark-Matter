function cancel(tasks, opt_user_message)
; %#ok Undocumented
%cancel  Cancel a task
%
% cancel(t) stops the task object, t, that has been submitted to a scheduler.
% The task's State property is set to finished, and any results that have
% been computed for the task object are saved and may be accessed normally. 
%
% cancel(t, 'message') cancels the task with an additional user-specified
% message. This message will be added to the default cancellation message.
%
% If the task is running in a scheduler attempts will be made through the
% scheduler to contact those workers and stop them. If the scheduler does
% not support this level of functionallity then the tasks will continue to
% be evaluated.
%
% Example:
%     jm = findResource('scheduler', 'type', 'lsf');
%     j  = createJob(jm);
%     t  = createTask(@rand, 1, {1});
%     submit(j);
%     cancel(t);
%
% See also distcomp.job/submit, distcomp.job/cancel

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.4 $    $Date: 2008/05/05 21:35:45 $ 

currentUser = char(java.lang.System.getProperty('user.name'));
currentHost = char(java.net.InetAddress.getLocalHost.getCanonicalHostName);
message = sprintf('Task cancelled by user: %s on machine: %s', currentUser, currentHost);
if nargin > 1    
    message = sprintf( '%s\nwith message: %s', message, opt_user_message );
end
for i = 1:numel(tasks)
    thisTask = tasks(i);
    try
        % Get a serializer for the task
        serializer = thisTask.Serializer;
        taskState = serializer.getField(thisTask, 'state');
        jobState = thisTask.Parent.State;
        % Check if this task is finished
        if ~strcmp(taskState, 'finished')
            OK_TO_CANCEL = strcmp(jobState, 'pending');
            % Ask the scheduler if it thinks we can cancel this task
            if ~OK_TO_CANCEL
                try
                    scheduler = thisTask.pGetManager;
                    OK_TO_CANCEL = scheduler.pCancelTask(thisTask);
                catch err
                    warning('distcomp:task:SchedulerError', ...
                        'Unable to cancel task because the scheduler threw an error. Nested error:\n%s', err.message);
                    OK_TO_CANCEL = false;
                end
            end
            % If the scheduler indicates that it did not manage to cancel the 
            % task then we shouldn't write anything to the task.
            if OK_TO_CANCEL
                % Now write the cancel message to the tasks
                thisTask.Serializer.putFields(thisTask, ...
                    {'erroridentifier', 'errormessage', 'finishtime' 'state'}, ...
                    {'distcomp:task:Cancelled', message, char(java.util.Date) 'finished'});
            end
        end
    catch err
        % TODO
        rethrow(err)
    end
end