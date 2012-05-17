function myOK = wait(job, varargin)
%wait Wait for job object to change state
%
%    wait(j) blocks execution in the client session until the job
%    identified by the job object j reaches the 'finished' state. This occurs
%    when all its tasks are finished processing on remote workers.
%    
%    wait(j, 'State') blocks execution in the client session until the
%    job object changes state to the value of 'state'. For a job object the
%    valid states are 'queued', 'running' and 'finished'.
%    
%    OK = wait(j, 'State', timeout) blocks execution until timeout
%    seconds elapse or the job reaches the specified 'State', whichever
%    happens first. OK is true if state has been reached or false in case
%    of a timeout.
%    
%    If a job has previosuly been in state 'State', then wait will
%    return immediately. For example, if a job in the 'finished' state is asked
%    to wait(job, 'queued'), then the call will return immediately.
%    
%    Example:
%    % Create a job object.
%    jm = findResource('scheduler', 'type', 'jobmanager', ...
%                          'LookupURL', 'JobMgrHost');
%    j = createJob(jm);
%    % Add a task object that generates a 10x10 random matrix.
%    t = createTask(j, @rand, 1, {10,10});
%    % Run the job.
%    submit(j);
%    % Wait until the job is finished.
%    wait(j, 'finished');
%    
%    See also distcomp.job/waitForState uiwait waitfor

% Copyright 2007 The MathWorks, Inc.

% $Revision: 1.1.6.2 $  $Date: 2008/01/10 21:10:07 $

try
    OK = waitForState(job, varargin{:});
    if nargout == 1
        myOK = OK;
    end
catch exception
    throw(exception);
end 