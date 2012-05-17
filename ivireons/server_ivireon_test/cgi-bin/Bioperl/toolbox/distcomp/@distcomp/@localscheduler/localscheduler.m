function obj = localscheduler( proxyScheduler ) %#ok<INUSD>
; %#ok Undocumented
%LOCALSCHEDULER - local scheduler constructor

%  Copyright 2006-2009 The MathWorks, Inc.

%  $Revision: 1.1.6.9 $    $Date: 2009/07/14 03:52:57 $ 

if isdeployed
    % Can't use localscheduler from deployed application
    error( 'distcomp:localscheduler:NoLocalScheduler',...
        'Local scheduler can not be used in deployed applications.' );
elseif system_dependent( 'isdmlworker' )
    % or from workers
    error( 'distcomp:localscheduler:NoLocalScheduler',...
        'Local scheduler can not be created from workers.' );
end

obj = distcomp.localscheduler;
% Subdir to put data in - specific to a release of the tools
subDir = fullfile('local_scheduler_data', ['R' version('-release')]);
try
    % Get the directory one up from the prefdir
    baseDir = fileparts(prefdir);
    % Try making a new directory for the data location
    dirName = fullfile(baseDir, subDir);
catch exception %#ok<NASGU> This is a conceivable failure that we deal with
    dirName = fullfile(tempdir, subDir);
end
% Should we remove the dirName afterwards - it is unlikely
% that this will get called because JVM shutdown hooks and
% UDD destructors don't get called when matlab exits
obj.RemoveDataLocation = ~exist(dirName, 'dir');
% If the dirName doesn't exist we need to create it here
if obj.RemoveDataLocation
    OK = mkdir(dirName);
    if ~OK
        % Fallback to different directory name
        dirName = fullfile(tempdir, subDir);
        if ~exist(dirName, 'dir')
            [OK, msg, id] = mkdir(dirName);
            if ~OK
                % Failed to make the DataLocation is a bad sign - rethrow
                % to the user
                error(id, msg);
            end
        end
    end
end
% Make a new storage object here that uses the specified dirName
% ClusterSize must be equal to 4 for the local scheduler.
storage = distcomp.filestorage(dirName);
import com.mathworks.toolbox.distcomp.local.*
try
    localScheduler = LocalScheduler.getInstance;
    clusterSize = min(feature('numcores'), LocalConstants.sMAX_NUMBER_OF_WORKERS);
    % Make sure that the local scheduler instance is in tune with this
    % object;
    localScheduler.setMaximumNumberOfWorkers(clusterSize);
    pid = feature('getpid');
    procInfo = struct('pid', pid, 'pidname', dct_psname(pid), ...
        'hostname', char( java.net.InetAddress.getLocalHost.getCanonicalHostName ) );
    set( obj, ...
        'Type', 'local', ...
        'Storage', storage, ...
        'ClusterMatlabRoot', matlabroot, ...
        'HasSharedFilesystem', true, ...
        'ClusterSize', clusterSize, ...
        'LocalScheduler', localScheduler,...
        'MaximumNumberOfWorkers', LocalConstants.sMAX_NUMBER_OF_WORKERS, ...
        'ProcessInformation', procInfo);
catch err %#ok<NASGU> It's OK if we are unable to set these properties
end
% This class accepts configurations and uses the scheduler section.
sectionName = 'scheduler';
obj.pInitializeForConfigurations(sectionName);

% Need to listen for destruction of this object and allow clean up to occur
% l = handle.listener(obj, 'ObjectBeingDestroyed', @iBeingDestroyed);
% obj.Listeners = [obj.Listeners l];
% Indicate that we have finished initializing the object
obj.Initialized = true;

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
% function iBeingDestroyed(obj, event) %#ok<INUSD>
% if obj.RemoveDataLocation
%     dirName = obj.DataLocation;
%     % Turn off CouldNotRemove warning
%     warningState = warning('off', 'MATLAB:RMDIR:CouldNotRemove');
%     % Then remove any directories
%     if exist(dirName, 'dir')
%         rmdir(dirName, 's');
%     end
%     warning(warningState);
%     % If the directory still exists then lets ask the JVM to remove it when
%     % it terminates
%     if exist(dirName, 'dir') && usejava('jvm')
%         import com.mathworks.toolbox.distcomp.util.FileDeleter;
%         FileDeleter.getInstance.deleteFileLater(java.io.File(dirName));
%     end
% end
