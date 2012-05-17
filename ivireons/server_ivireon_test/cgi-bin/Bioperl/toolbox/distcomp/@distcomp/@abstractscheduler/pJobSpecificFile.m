function [clientName, clusterName] = pJobSpecificFile( obj, job, nameInsideDir, isOkIfNoClusterStorage )
; %#ok Undocumented
%pJobSpecificFile - return the full path to a file within the job subdirectory
% with correct slashes etc.

% Copyright 2006-2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2007/11/09 19:50:00 $

storage = job.pReturnStorage;
if isa( storage, 'distcomp.filestorage' )
    winDir = storage.WindowsStorageLocation;
    unixDir = storage.UnixStorageLocation;
    jobSubDir = job.pGetEntityLocation;

    if ispc
        clientType = 'pc';
        clientDir = fullfile( winDir, jobSubDir );
    else
        clientType = 'unix';
        clientDir = fullfile( unixDir, jobSubDir );
    end
    
    if strcmp( obj.ClusterOsType, 'pc' )
        gotClusterStorage = ~isempty( winDir );
        clusterDir = fullfile( winDir, jobSubDir );
    elseif strcmp( obj.ClusterOsType, 'unix' )
        gotClusterStorage = ~isempty( unixDir );
        clusterDir = fullfile( unixDir, jobSubDir );
    else
        % We've got a mixed cluster. Things are only OK if it's OK not to have
        % cluster storage.
        if ~isOkIfNoClusterStorage
            % Never get here - parallel submission doesn't allow mixed, and distributed
            % submission is OK with no cluster storage.
            error( 'distcomp:abstractscheduler:NoClusterStorage', ...
                   'Cannot calculate the cluster storage for a mixed cluster' );
        end

        % Just use the storage for the client
        gotClusterStorage = true;
        clusterDir = clientDir;
    end
    

    if gotClusterStorage || isOkIfNoClusterStorage
        % We're fine then - we'll just the nameInsideDir part
    else
        error( 'distcomp:abstractscheduler:NoClusterStorage', ...
               ['The scheduler is configured to use ''%s'' workers, \n', ...
                'but the DataLocation property of the scheduler does not include \n', ...
                'a location for that type of worker. You can specify the DataLocation \n', ...
                'as a structure by doing: \n', ...
                'scheduler.DataLocation = ', ...
                'struct( ''pc'', ''\\\\machine\\unc\\path'', ''unix'', ''/equivalent/path'' )'], ...
               obj.ClusterOsType );
    end
    
else
    clientDir = tempdir;
    clusterDir = tempdir;
end

if gotClusterStorage
    clusterName = iCorrectSlashes( fullfile( clusterDir, nameInsideDir ), obj.ClusterOsType );
else
    clusterName = nameInsideDir;
end
clientName  = iCorrectSlashes( fullfile( clientDir, nameInsideDir ), clientType );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iCorrectSlashes - set up slashes in a file name the right way
function correctPath = iCorrectSlashes( path, type )

% If the type is 'mixed', use the client type; else use the correct type.
if strcmp( type, 'mixed' )
    if ispc
        type = 'pc';
    else
        type = 'unix';
    end
end

if strcmp( type, 'unix' )
    correctPath = strrep( path, '\', '/' );
else
    correctPath = strrep( path, '/', '\' );
end