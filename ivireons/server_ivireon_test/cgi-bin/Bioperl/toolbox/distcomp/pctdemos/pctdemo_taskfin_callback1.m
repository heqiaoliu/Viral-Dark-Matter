function pctdemo_taskfin_callback1(task, eventdata)
%PCTDEMO_TASKFIN_CALLBACK1 Count the number of remaining tasks.
%   The function shows how the task finished callback function can access the 
%   UserData property of the job and modify it. 

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:06:03 $
     
    % The UserData property of the job is the counter for the number of 
    % remaining tasks.  We decrement it by one.
    job = task.Parent;
    numTasksLeft = get(job, 'UserData');
    numTasksLeft = numTasksLeft - 1;
    set(job, 'UserData', numTasksLeft);
    % Display a message about how many tasks there are left.
    if (numTasksLeft > 1)
        fprintf('There are now %d tasks left\n', numTasksLeft);
    elseif (numTasksLeft == 1)
        disp('There is now 1 task left');
    else
        disp('Finished with all the tasks');
    end
end % End of pctdemo_taskfin_callback1.
