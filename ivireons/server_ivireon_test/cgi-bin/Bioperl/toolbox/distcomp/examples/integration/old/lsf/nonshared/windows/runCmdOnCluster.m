function runCmdOnCluster(command, clusterHost)
%RUNCMDONCLUSTER Runs a command on a remote host.

% Copyright 2006 The MathWorks, Inc.

% Use plink (PuTTY Link) to run a command on the remote host. We assume 
% that the user has created a Putty session with the same name as 
% clusterHost.
cmdForCluster = sprintf('plink -load %s "%s"', clusterHost, command);

[s, r] = system(cmdForCluster);
if s ~= 0
    error('distcomp:scheduler:FailedRemoteOperation', ...
        ['Failed to run the command\n' ...
        '"%s"\n"' ...
        'on the host "%s".\n' ...
        'Command Output:\n' ...
        '"%s"\n' ...
        ], command, clusterHost, r);
else
    fprintf('%s\n', r);
end
