function [worker, mlcmd, args] = pCalculateMatlabCommandForJob( obj, job )
; %#ok Undocumented
%pCalculateMatlabCommandForJob - calculate MatlabCommandToRun
%   This uses knowledge about the job type and the useSoa property on the scheduler

%  Copyright 2008-2009 The MathWorks, Inc.

%  $Revision: 1.1.6.3 $ $Date: 2009/04/15 22:57:45 $

if ~strcmp( obj.ClusterOsType, 'pc' )
    error( 'distcomp:ccsscheduler:incompatibleSetting', ...
           'ClusterOsType must be ''pc'' for HPC Server schedulers.' );
else
    % Set the prototypical mlcmd - later we'll prepend ClusterMatlabRoot if set
    mlcmd = 'worker.bat';
    goodSlash = '\'; badSlash = '/';
end

% Choose the args for mlcmd
if isa( job, 'distcomp.simpleparalleljob' )
    args = ' -parallel';
else
    % this is a distributed job, so check for soa
    if obj.UseSOAJobSubmission
        % The C# code in MathWorks.MdcsService.MLWorkerWrapper will replace 
        % this channel name with something sensible
        ipcChannelName = '%PCTIPC_CHANNEL_NAME%';
        args = sprintf(' -ipc %s', ipcChannelName);
    else
        args = '';
    end
end

% We can now create the old-style MatlabCommandToRun
worker = [ mlcmd, args ];

% Finally, if necessary, prepend the ClusterMatlabRoot
if ~isempty( obj.ClusterMatlabRoot )
    mlcmd = fullfile( obj.ClusterMatlabRoot, 'bin', mlcmd );
    mlcmd = strrep( mlcmd, badSlash, goodSlash );
end
    

