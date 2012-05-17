function val = pSetClusterVersion(ccs, val)
; %#ok Undocumented
% Verifies that the Microsoft cluster client utilities exist for the specified
% cluster version and sets the ClusterVersion property.

%  Copyright 2009 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $  $Date: 2009/04/15 22:58:03 $

if ~ccs.HaveTestedForMicrosoftClientUtilities
    % If we haven't tested for client utilities yet, do nothing. 
    return;
end

% During construction, do not try to create the actual connection when the cluster version
% is set because the SchedulerHostname will still be the Factory value, which we know
% is very likely not to be a valid scheduler hostname.  Instead, let the ServerConnection 
% be created when the SchedulerHostname is set to the CCP_SCHEDULER value.
if ~ccs.Initialized
    return;
end

% Check that we could in theory create a server connection using 
% the specified cluster version (i.e. the client utility libraries can be 
% located for the specified version).  This needs to be done here even though
% it is (likely to be) done in ccs.pGetTempConnectionToScheduler because we 
% need to error if the correct libraries are not installed.  
%
% In other words - it is an ERROR to set the cluster version to a particular
% value if you do not have those client libraries installed.  However, it is
% perfectly valid to specify a cluster version for a scheduler to which we 
% are unable to establish a connection - we'll just warn in this case and the 
% server connection will be empty.
try
    ccs.pCreateNewServerConnection(val);
catch err
    % Now turn on all warnings in the HPCServerSchedulerConnection constructor
    %distcomp.HPCServerSchedulerConnection.turnOnConstructorWarnings
    ex = MException('distcomp:ccsscheduler:CannotSetClusterVersion', ...
        'Failed to use cluster client utilities for version %s', val);
    ex = ex.addCause(err);
    throw(ex);
end

% Replace the current server connection with one that is using the correct API and 
% is connected to the correct scheduler.
try
    ccs.ServerConnection = ccs.pGetTempConnectionToScheduler(ccs.SchedulerHostname, val);
catch err %#ok<NASGU>
    % Warn that we couldn't connect to the scheduler.
    ccs.ServerConnection = [];
    warning('distcomp:ccsscheduler:UnableToConnect', ...
        'Unable to contact a %s scheduler on machine %s', val, ccs.SchedulerHostname);
end
