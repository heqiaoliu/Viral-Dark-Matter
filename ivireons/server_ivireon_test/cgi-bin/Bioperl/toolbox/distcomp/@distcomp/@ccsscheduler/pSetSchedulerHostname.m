function val = pSetSchedulerHostname(obj, val)
%pSetServerHostname
%
%  val = pSetServerHostname(JOB, val)

%  Copyright 2006-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.4 $    $Date: 2010/04/21 21:13:57 $

if ~obj.HaveTestedForMicrosoftClientUtilities
    % If we haven't tested for client utilities yet, do nothing.
    return;
end

% Replace the current server connection with one that is using the correct API and
% is connected to the correct scheduler.
try
    obj.ServerConnection = obj.pGetTempConnectionToScheduler(val, obj.ClusterVersion);
catch err
    % Warn that we couldn't connect to the scheduler.
    obj.ServerConnection = [];
    dctSchedulerMessage(1, 'Error occurred when getting scheduler connection: \n%s', err.getReport);
    warning('distcomp:ccsscheduler:UnableToConnect', ...
        'Unable to contact a %s scheduler on machine %s', obj.ClusterVersion, val);
end
