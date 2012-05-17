function obj = lsfscheduler(proxyScheduler)
; %#ok Undocumented
%LSFSCHEDULER concrete constructor for this class
%
%  OBJ = LSFSCHEDULER(OBJ)

%  Copyright 2000-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.6 $    $Date: 2008/11/24 14:56:52 $


obj = distcomp.lsfscheduler;

% Some environment variables will cause our LSF integration to fail. These
% must be unset rather than set to empty before we can proceed with job
% submission
pctunsetenv('BSUB_QUIET');

[masterName, clusterName] = iParseOutputFromLsid;

set(obj, ...
    'Type', 'lsf', ...
    'Storage', handle(proxyScheduler.getStorageLocation), ...
    'ClusterName', clusterName, ...
    'MasterName', masterName, ...
    'HasSharedFilesystem', true );

% Set up the object for parallel execution - default to assuming that the
% cluster is the same type as the client.
if ispc
    workerType = 'pc';
else
    workerType = 'unix';
end
obj.setupForParallelExecution( workerType );

% This class accepts configurations and uses the scheduler section.
sectionName = 'scheduler';
obj.pInitializeForConfigurations(sectionName);

end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function [masterName, clusterName] = iParseOutputFromLsid
% Better check that there actually is an lsf scheduler available - call the
% LSF lsid command to get information about my cluster
[FAILED, out] = dctSystem('lsid');
% Possible that lsid isn't a file I can execute
if FAILED
    if ispc
        % Let's try and detect the 'not found' error which indicates that LSF
        % isn't on the path - need to search for special strings in the system
        % output to pick up these situations
        searchString = 'is not recognized as an internal or external command';
        NOT_FOUND = ~isempty(regexp(out, searchString, 'once'));
    else
        % Not sure what shell we are using so try calling which in /bin/sh
        % to see what it thinks of the output
        [FOUND, whichOut] = dctSystem('/bin/sh -c "which lsid"');
        switch lower(computer)
            case {'glnx86', 'glnxa64'}
                % On linux the exit code of which is sufficient to indicate it
                % the command lsid exists or not
                NOT_FOUND = FOUND ~= 0;
            otherwise % sol2, mac, hpux?
                % BSD-like platforms however don't have the same which and we 
                % need to parse the output of which for the string 'no lsid in'
                NOT_FOUND = ~isempty(regexpi(whichOut, 'no lsid in'));
        end
    end
    if NOT_FOUND
        error('distcomp:lsfscheduler:UnableToFindService', ...
           ['findResource is reporting an error because lsid is not on your path.\n' ...
           'Most likely this is because your computer is not set up as a client on an LSF cluster\n' ...
           'or the LSF scripts are not on your path%s'], '.');
    else
        error('distcomp:lsfscheduler:UnableToFindService', ...
            'Error executing the LSF script command ''lsid''. The reason given is \n %s', out);
    end
end

allEndIndex = regexp(out, '\n') - 1;
% Lets try and parse the output from out to get the relevant information
clusterStr = 'My cluster name is ';
masterStr  = 'My master name is ';

startClusterIndex = regexp(out, clusterStr) + numel(clusterStr);
endClusterIndex   = min(allEndIndex(allEndIndex > startClusterIndex));

startMasterIndex  = regexp(out, masterStr) + numel(masterStr);
endMasterIndex    = min(allEndIndex(allEndIndex > startMasterIndex));

clusterName = out(startClusterIndex:endClusterIndex);
masterName  = out(startMasterIndex:endMasterIndex);
end
