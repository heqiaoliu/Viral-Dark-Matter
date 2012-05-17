function sfLinks = machine_bind_sflinks(machineId, doFindSystem)
%
% Find all sflinks in this model and bind them to said machine.
%

% Copyright 2002-2008 The MathWorks, Inc.

   if(ischar(machineId))
      modelH = get_param(machineId,'Handle');
      machineId = sf('find',sf('MachinesOf'),'machine.name',machineId);
   else
      modelH = sf('get', machineId, '.simulinkModel');
   end
   
   % if the current model contains Simulink library blocks that point
   % to old Simulink library models, SL spits out ugly warnings that say
   %    Warning: Run 'slupdate('oldmodel')' to convert the block diagram to
   %    the format of the current version of Simulink.
   % This is normally shown with callstack, which gives users an impression
   % that these warnings are from slsf and hence to do with Stateflow.
   % Furthermore, these warnings are causing tremendous slow-downs in
   % presence of unresolved library blocks. we set the warning status to
   % 'off' to suppress callstack display and restore it later.
   
   warnStatus = warning('off', 'all');
   allBlocks = find_system(modelH, 'AllBlocks', 'on', 'LookUnderMasks', 'on', 'FollowLinks', 'on', 'LookUnderReadProtectedSubsystems', 'on', 'MaskType', 'Stateflow');
   blocks = find_system(modelH,  'LookUnderMasks', 'on', 'FollowLinks', 'on', 'LookUnderReadProtectedSubsystems', 'on', 'MaskType', 'Stateflow');
   
   viewerBlocks = vset(allBlocks,'-',blocks);
   
   if (~isempty(viewerBlocks))
       viewerChart = block2chart(viewerBlocks(1)); % Report on the first viewer sf block
       viewerChartName = sf('FullNameOf', viewerChart, '/');
       errMsg = sprintf('Blcok ''%s'' (#%d) cannot be placed in Signal Viewer.', viewerChartName, viewerChart);
       errMsg = sprintf('%s\n%s', errMsg, 'Stateflow, Truth Table, and Embedded MATLAB blocks are not supported in Signal Viewers.');
       construct_error(viewerChart, 'Build', errMsg, 1);
   end
   
   % g468046: Since this function is called before links are resolved by
   % Simulink, SF charts inside linked SF charts might have been
   % invalidated, causing the get_param below to fail.
   try
       get_param(blocks, 'linkstatus');
   catch ME
       if ~strcmpi(ME.identifier, 'Simulink:Commands:InvSimulinkObjHandle')
           rethrow(ME);
       end
       % Filter out stuff which got invalidated.
       blocks = blocks(ishandle(blocks));
   end
   
   warning(warnStatus);
   sfLinks = sf('get',machineId,'machine.sfLinks');
   % XXX: SA: Should we add 'SearchDepth', 0 to find_system below?
   nonLinkBlocks = find_system(blocks,'referenceblock','');
   linkBlocks = vset(blocks,'-',nonLinkBlocks);
   if(~vset(linkBlocks,'==',sfLinks))
       % an attempt to patch up sfLinks. force it to a row. 
       % Otherwise sf('set') gets confused and picks up only the first element.
       sf('set',machineId,'machine.sfLinks',linkBlocks(:)');
       sfLinks = linkBlocks;
   end
