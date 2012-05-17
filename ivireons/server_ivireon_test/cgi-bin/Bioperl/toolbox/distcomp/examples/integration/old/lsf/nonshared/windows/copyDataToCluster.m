function copyDataToCluster(localLoc, remoteLoc, clusterHost)
%COPYDATATOCLUSTER Copies files or directories from the local machine
% to a location on a remote host.

% Copyright 2006-2008 The MathWorks, Inc.

% Use pscp (PuTTY scp) to copy files. We assume that the user has 
% created a Putty session with the same name as clusterHost.
copyCmd = sprintf('pscp -r -v -scp -unsafe -load %s "%s" "%s:%s"', ...
    clusterHost, localLoc, clusterHost, remoteLoc);

[s, r] = system(copyCmd);
if s ~= 0
    error('distcomp:scheduler:FailedRemoteOperation', ...
        ['Failed to copy files from "%s"\n' ...
        'to "%s" on the host "%s".\n' ...
        'Command Output:\n' ...
        '"%s"\n' ...
        ], localLoc, remoteLoc, clusterHost, r);
end
