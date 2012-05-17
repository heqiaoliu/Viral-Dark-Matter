function [wasSubmitted, isMpi, isAlive, pid, whyNotAlive] = pInterpretJobSchedulerData( obj, job )
; %#ok Undocumented
% pInterpretJobSchedulerData - interpret the job scheduler data and return status flags
%
% - wasSubmitted is true iff it looks like the job was submitted
% - isMpi is true iff wasSubmitted is true AND the job has valid
%   MPIEXEC scheduler data (returns "false" for old jobs) 
% - isAlive is true iff isMpi is true AND the PID is alive AND the PID has
%   the correct name AND we're on the right client
% - pid is the pid if the job if isAlive is true, else -1
% - whyNotAlive.reason is one of {'wrongclient', 'wrongpidname', 'pidnotalive', 'wrongjobtype', 'notsubmitted'}
% - whyNotAlive.description is a textual description of why the process is not considered to be alive

% Copyright 2006 The MathWorks, Inc.

% defaults
wasSubmitted = false;
isMpi        = false;
isAlive      = false;
pid          = -1;
whyNotAlive  = struct( 'reason', 'notsubmitted', ...
                       'description', ...
                       sprintf( 'job %d has not yet been submitted', job.ID ) );

data = job.pGetJobSchedulerData;
if isempty( data )
    % use defaults
    return
else
    wasSubmitted = true;
end

if strcmp( data.type, 'mpiexec' ) && isfield( data, 'pid' )
    isMpi = true;
else
    whyNotAlive  = struct( 'reason', 'wrongjobtype', ...
                           'description', ...
                           sprintf( 'job %d is not a valid MPIEXEC job', job.ID ) );
    return
end

% Check the pid for validity before returning it to anyone
if strcmp( data.pidhost, obj.ClientHostName )
    % We can start checking things to do with the PID
    if data.pid > 0 
        [pidname, isAlive] = dct_psname( data.pid );
        if isAlive
            if strcmp( data.pidname, pidname )
                % Process is alive, and name matches
                pid = data.pid;
                whyNotAlive = struct( 'reason', '', ...
                                      'description', '' );
            else
                % Wrong process name
                isAlive     = false;
                whyNotAlive = struct( 'reason', 'wrongpidname', ...
                                      'description', ...
                                      sprintf( 'the PID (%d) associated with job %d did not have the expected name', ...
                                               data.pid, job.ID ) );
            end
        else
            whyNotAlive = struct( 'reason', 'pidnotalive', ...
                                  'description', ...
                                  sprintf( 'the PID (%d) associated with job %d is no longer alive', ...
                                           data.pid, job.ID ) );
        end
    else
        % invalid pid
        whyNotAlive = struct( 'reason', 'pidnotalive', ...
                              'description', ...
                              sprintf( 'job %d no longer has a valid PID', job.ID ) );
    end
else
    whyNotAlive = struct( 'reason', 'wrongclient', ...
                          'description', ...
                          sprintf( 'job %d was submitted from client %s', job.ID, data.pidhost ) );
end
    