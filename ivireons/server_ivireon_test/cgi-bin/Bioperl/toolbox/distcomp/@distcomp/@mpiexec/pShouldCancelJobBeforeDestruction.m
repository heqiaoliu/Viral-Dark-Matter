function shouldCancel = pShouldCancelJobBeforeDestruction( ~, job )
; %#ok Undocumented
%pShouldCancelJobBeforeDestruction - do we need to attempt job cancellation
%before allowing destruction. This is based solely on the job state.

%  Copyright 2005-2008 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $    $Date: 2010/05/10 17:03:23 $ 

% stash the date format that we use to interpret job.FinishTime
persistent dateFormat

if isempty( dateFormat )
    % See the javadoc for java.util.Date - this is precisely the format that we expect
    % from the "toString" method of a java.util.Date - something like 
    % "Tue Mar 28 11:41:15 BST 2006". Note that 
    % date = java.util.Date;
    % java.util.Date( date.toString )
    % doesn't work!
    dateFormat = java.text.SimpleDateFormat( 'E MMM dd H:m:s z yyyy', java.util.Locale.US );
end

% LOGIC: if the job is queued or running, we must cancel the job before
% destruction. Additionally, if the job has been marked finished in the last
% TIMEOUT, then we should kill the mpiexec process in any case to make sure
% that no-one is trying to write into the job directory. This is not
% foolproof.

jobState = job.State;

switch jobState
  case {'pending', 'unavailable', 'destroyed', 'failed'}
    % never cancel these states
    shouldCancel = false;
  case {'queued', 'running'}
    % always cancel
    shouldCancel = true;
  case 'finished'
    % This is the amount by which a job must have been finished by in order not
    % to attempt to kill the PID if we can. This timeout can be really long
    % because if destroy is called on the submission client, then
    % cancellation of an already-gone mpiexec process doesn't cause any
    % warnings etc.
    FINISHED_TIMEOUT_MILLIS = 600000;
    
    jobfinished = job.FinishTime;
    if isempty( jobfinished )
        % How did we get here? Job must be finished, but we don't have a finish
        % time. Don't warn though as it is not a useful warning
        % don't try to cancel
        shouldCancel = false;
    else
        % Check finish time to see if we should 
        nowDateObj             = java.util.Date;
        try
            jobfinishedDateObj = dateFormat.parse( jobfinished );
        catch E %#ok<NASGU> Don't need information from the parse error
            % parse error - warn and break out early
            warning( 'distcomp:mpiexec:dateFormat', ...
                     'Couldn''t interpret job''s FinishTime "%s"', jobfinished );
            shouldCancel = false;
            return
        end
        finishedByMillis       = nowDateObj.getTime - jobfinishedDateObj.getTime;
        
        % Cancel if job finished within FINISHED_TIMEOUT of now. 
        shouldCancel       = finishedByMillis < FINISHED_TIMEOUT_MILLIS;
    end
end
