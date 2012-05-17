function copyDataFromCluster(localLoc, remoteLoc, clusterHost)
%COPYDATAFROMCLUSTER Copies files or directories from a location
% on a remote host to the local machine.

% Copyright 2006-2008 The MathWorks, Inc.

% Use pscp (PuTTY scp) to copy files. We assume that the user has 
% created a Putty session with the same name as clusterHost.
copyCmd = sprintf('pscp -r -v -scp -unsafe -load %s "%s:%s" "%s"', ...
    clusterHost, clusterHost, remoteLoc, localLoc);

[s, r] = system(copyCmd);
if s ~= 0
    error('distcomp:scheduler:FailedRemoteOperation', ...
        ['Failed to copy files from "%s" on the host "%s"\n' ...
        'to "%s".\n' ...
        'Command Output:\n' ...
        '"%s"\n' ...
        ], remoteLoc, clusterHost, localLoc, r);
end
