function val = pCreateNewServerConnection(~, clusterVersion)
; %#ok Undocumented
% Static function to create an instance of the correct type of scheduler
% connection based on the specified cluster version.
%
% Valid values of clusterVersion are distcomp.microsoftclusterversion enum strings
% 'CCS' and 'HPCServer2008'

%  Copyright 2009 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $  $Date: 2009/04/15 22:57:49 $

try
    switch clusterVersion
        case distcomp.CCSSchedulerConnection.getAPIVersion
            val = distcomp.CCSSchedulerConnection;
        case distcomp.HPCServerSchedulerConnection.getAPIVersion
            val = distcomp.HPCServerSchedulerConnection;
        otherwise
            % Doubt we'll ever get in here
            error('distcomp:ccsscheduler:UnknownClusterVersion', ...
                '%d is an unknown Cluster Version.', clusterVersion);
    end
catch err
    % convert from a ServerConnection error to a ccsscheduler error, if necessary.
    % (Only actually required for distcomp:CCSSchedulerConnection:UnableToContactService
    % and distcomp:HPCServerSchedulerConnection:UnableToContactService)
    throw(distcomp.MicrosoftSchedulerConnectionExceptionManager.convertToCCSSchedulerError(err));
end



