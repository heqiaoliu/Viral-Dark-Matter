function [worker, mlcmd, args] = pCalculateMatlabCommandForJob( obj, job )
; %#ok Undocumented
%pCalculateMatlabCommandForJob - calculate MatlabCommandToRun
%   This uses knowledge about the ClusterOsType and the job type

% Copyright 2006 - 2010 The MathWorks, Inc.

% $Revision: 1.1.6.3 $ $Date: 2010/01/25 21:30:59 $

% Set the prototypical mlcmd - later we'll prepend ClusterMatlabRoot if set
if ispc
    mlcmd = fullfile(dct_arch, 'matlab.exe');
    args = {'-dmlworker', '-noFigureWindows', sprintf('-c "%s"', feature('lmsearchpath')),'-r distcomp_evaluate_filetask'};
else    
    % If the worker type is 'mixed', then just tell them to run "worker", as
    % that will work under most circumstances. The only time running
    % "worker" doesn't work on PC is when you want to run "worker" under
    % mpiexec.
    mlcmd = 'worker';
    args = {sprintf('-c ''%s''', feature('lmsearchpath'))};
    % Choose the args for mlcmd
    if isa( job, 'distcomp.simpleparalleljob' )
        args{end+1} = '-parallel';
    end
end
% Take the cell array of args and put into a single string
args = sprintf('%s ', args{:});

% Finally, if necessary, prepend the ClusterMatlabRoot
if ~isempty( obj.ClusterMatlabRoot )
    mlcmd = fullfile( obj.ClusterMatlabRoot, 'bin', mlcmd );
end
    
% We can now create the old-style MatlabCommandToRun - but lets not since
% this scheduler shouldn't use this form
worker = '';
