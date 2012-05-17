function [machineType, wrapperScript] = pSetupForParallelExecution( pbs, type, doSetMachineType, doSetWrapperScript )
; %#ok Undocumented
%pSetupForParallelExecution - does the work for setupForParallelExecution

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2008/08/26 18:13:36 $

switch lower( type )
  case {'pc', 'pcnodelegate'}
    if strcmpi( type, 'pcnodelegate' )
        scriptTail = 'pbsParallelWrapperNoDelegate.bat';
    else
        scriptTail = 'pbsParallelWrapper.bat';
    end
    machineType = 'pc';
  case 'unix'
    scriptTail  = 'pbsParallelWrapper.sh';
    machineType = 'unix';
  otherwise
    error( 'distcomp:pbsscheduler:invalidParallelExecutionType', ...
           'The valid types for setupForParallelExecution are: ''pc'', ''pcNoDelegate'', or ''unix''' );
end

wrapperScript = fullfile( toolboxdir('distcomp'), 'bin', 'util', 'pbs', scriptTail );

if doSetMachineType
    pbs.ClusterOsType = machineType;
end

if doSetWrapperScript
    pbs.ParallelSubmissionWrapperScript = wrapperScript;
end
