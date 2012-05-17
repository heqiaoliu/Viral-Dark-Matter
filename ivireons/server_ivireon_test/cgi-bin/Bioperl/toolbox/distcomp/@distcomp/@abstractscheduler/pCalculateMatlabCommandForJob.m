function [worker, mlcmd, args] = pCalculateMatlabCommandForJob( obj, job )
; %#ok Undocumented
%pCalculateMatlabCommandForJob - calculate MatlabCommandToRun
%   This uses knowledge about the ClusterOsType and the job type

% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/06/27 22:34:48 $

if strcmp( obj.ClusterOsType, 'mixed' ) && ~isempty( obj.ClusterMatlabRoot )
    error( 'distcomp:abstractscheduler:incompatibleSetting', ...
           'You must not specify a value for ClusterMatlabRoot when the ClusterOsType is ''mixed''' );
end

% Set the prototypical mlcmd - later we'll prepend ClusterMatlabRoot if set
switch obj.ClusterOsType
  case 'pc'
    mlcmd = 'worker.bat';
    goodSlash = '\'; badSlash = '/';
  case {'unix', 'mixed'}
    % If the worker type is 'mixed', then just tell them to run "worker", as
    % that will work under most circumstances. The only time running
    % "worker" doesn't work on PC is when you want to run "worker" under
    % mpiexec.
    mlcmd = 'worker';
    goodSlash = '/'; badSlash = '\';
  otherwise
    error( 'distcomp:abstractscheduler:unknownOsType', ...
           'Unknown ClusterOsType: %s', obj.ClusterOsType );
end

% Choose the args for mlcmd
if isa( job, 'distcomp.simpleparalleljob' )
    args = ' -parallel';
else
    args = '';
end

% We can now create the old-style MatlabCommandToRun
worker = [ mlcmd, args ];

% Finally, if necessary, prepend the ClusterMatlabRoot
if ~isempty( obj.ClusterMatlabRoot )
    mlcmd = fullfile( obj.ClusterMatlabRoot, 'bin', mlcmd );
    mlcmd = strrep( mlcmd, badSlash, goodSlash );
end
    

