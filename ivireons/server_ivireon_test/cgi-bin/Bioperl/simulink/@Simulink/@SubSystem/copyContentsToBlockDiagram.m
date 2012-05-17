function copyContentsToBlockDiagram(subsys, bd)
% copyContentsToBlockDiagram copies contents of a subsystem to a block diagram
%
% Simulink.SubSystem.copyContentsToBlockDiagram copies contents of a 
% subsystem, i.e., blocks, lines, notes (annotations), to a block diagram.
%
% Usage: Simulink.SubSystem.copyContentsToBlockDiagram(subsys, bd)
% Inputs:
%    subsys: a subsystem name or handle
%    bd: a block diagram name or handle
%
    
%  Copyright 1994-2006 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $
  if nargin ~= 2
      DAStudio.error('Simulink:modelReference:slSSCopyContentsToBDInvalidNumInputs');
  end
    
  % Check the first input argument
  try
      isSubsys = strcmpi(get_param(subsys,'type'), 'block') && ...
          strcmpi(get_param(subsys,'blocktype'), 'Subsystem');
  catch
      isSubsys = false;
  end
  
  if ~isSubsys
      DAStudio.error('Simulink:modelReference:slSSCopyContentsToBDIn1Invalid');
  end
  
  
  % Check the second input argument. Bd must be loaded
  try
      isBd = strcmpi(get_param(bd,'type'), 'block_diagram');
  catch
      isBd = false;
  end
  
  if ~isBd
      DAStudio.error('Simulink:modelReference:slSSCopyContentsToBDIn2Invalid');
  end

  % Make sure bd is not being compiled
  bdSimStatus = get_param(bd,'SimulationStatus');
  if ~strcmpi(bdSimStatus, 'stopped')
      bdName= get_param(bd, 'name');
      DAStudio.error('Simulink:modelReference:slBadSimStatus', bdName, bdSimStatus);
  end

  % Now copy contents.  Undocumented APIs. Do not use them directly
  bdH = get_param(bd,'handle');
  ssObj = get_param(subsys,'object');
  ssObj.copyContentsToBD(bdH);
  
%endfunction

