function value = pSetParallelSubmissionWrapperScript( pbs, value )
; %#ok Undocumented
%pSetParallelSubmissionWrapperScript - update the wrapper script
% and interpret special values - special values are passed directly to
% "pSetupForParallelExecution".

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2007/11/09 19:51:04 $

switch lower( value )
  case {'pc', 'pcnodelegate', 'unix'}
    % Don't set the machine type or wrapper script - just query the values that
    % would be set. We'll ignore the machineType here.
    [machineType, value] = pbs.pSetupForParallelExecution( value, false, false );
  otherwise
    % Do nothing - just set the value
end