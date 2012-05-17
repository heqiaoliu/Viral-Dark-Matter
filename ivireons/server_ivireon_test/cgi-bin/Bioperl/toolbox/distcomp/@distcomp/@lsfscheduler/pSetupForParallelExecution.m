function [machineType, wrapperScript] = pSetupForParallelExecution( lsf, type, doSetMachineType, doSetWrapperScript )
; %#ok Undocumented
%pSetupForParallelExecution - does the work for setupForParallelExecution

% Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.6.4 $   $Date: 2008/08/26 18:13:29 $

switch lower( type )
  case {'pc', 'pcnodelegate'}
    if strcmpi( type, 'pcnodelegate' )
        scriptTail = 'lsfWrapMpiexecNoDelegate.bat';
    else
        scriptTail = 'lsfWrapMpiexec.bat';
    end
    machineType = 'pc';
  case 'unix'
    scriptTail = 'lsfWrapMpiexec.sh';
    machineType = 'unix';
  otherwise
    error( 'distcomp:lsfscheduler:invalidParallelExecutionType', ...
           'The valid types for setupForParallelExecution are: ''pc'', ''pcNoDelegate'', or ''unix''' );
end

wrapperScript = fullfile( toolboxdir('distcomp'), 'bin', 'util', scriptTail );

if doSetMachineType
    lsf.ClusterOsType = machineType;
end

if doSetWrapperScript
    lsf.ParallelSubmissionWrapperScript = wrapperScript;
end
