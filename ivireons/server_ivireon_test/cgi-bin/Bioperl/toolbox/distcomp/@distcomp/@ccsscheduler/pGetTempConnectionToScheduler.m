function conn = pGetTempConnectionToScheduler(ccs, name, version)
%pGetTempConnectionToScheduler -
% Get a connection to a given scheduler - this might be the one cached in
% the CCS object or a new one that will be disconnected afterwards.
%
% We maintain a map of the connections to ensure that scheduler connection properties 
% (e.g. UseSOAJobSubmission, JobTemplate, MaximumNumberOfWorkersPerJob) are not changed
% when we need a temp connection to a scheduler with a different hostname/version.  We don't
% want these properties to be reset to the default values every time pGetTempConnectionToScheduler
% is called (e.g. from getDebugLog.m).  
%
%  Copyright 2006-2009 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2009/04/15 22:57:57 $

% mlock this file to ensure the serverConnectionMapArray never gets deleted
mlock
% ServerConnectionMapArray is a cell array of containers.Map using the scheduler 
% hostnames (always uppercase) as keys to access distcomp.HPCServerSchedulerConnection objects
% and distcomp.CCSSchedulerConnection objects.  The index into the cell array is dictated by the 
% enum value distcomp.microsoftclusterversion.  
persistent serverConnectionMapArray

clusterVersionType = findtype('distcomp.microsoftclusterversion');

% Create the serverConnectionMapArray if it doesn't already exist
if isempty(serverConnectionMapArray)
    numClusterVersions = length(clusterVersionType.Values);
    serverConnectionMapArray = cell(numClusterVersions, 1);
    % Create the maps
    for i = 1:numClusterVersions
        serverConnectionMapArray{i} = containers.Map;
    end
end

% Lets get a connection - if the one we have is already connected
% to the specified hostname using the correct version (as is likely)
% then use it
conn = ccs.ServerConnection;
if ~isempty(conn) && strcmpi(conn.getAPIVersion, version) && conn.isConnectedToScheduler(name)
    return;
end

try
    mapIndex = clusterVersionType.Values(strcmpi(clusterVersionType.Strings, version));
    if isempty(mapIndex)
        % version was invalid.  Doubt we'll ever get in here.
        error('distcomp:ccsscheduler:UnknownClusterVersion', ...
            '%d is an unknown Cluster Version.', clusterVersion);
    end

    connectionMap = serverConnectionMapArray{mapIndex};
    % See if we have a scheduler connection in the Map for the desired name
    upperHostname = upper(name);
    if connectionMap.isKey(upperHostname)
        conn = connectionMap(upperHostname);
    else
        % create a new SchedulerConnection, connect it and add it
        % to the map.
        conn = ccs.pCreateNewServerConnection(version);
        conn.connect(name);
        connectionMap(upperHostname) = conn; %#ok<NASGU>
    end
catch err
    ex = MException('distcomp:ccsscheduler:UnableToContactService', ...
        'Unable to contact scheduler with version %s and hostname %s', version, name);
    ex = ex.addCause(err);
    throw(ex);
end
