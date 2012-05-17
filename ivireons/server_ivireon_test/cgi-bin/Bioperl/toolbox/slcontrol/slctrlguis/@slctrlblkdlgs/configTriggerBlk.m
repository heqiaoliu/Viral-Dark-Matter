function configTriggerBlk(hBlk) 

% Author(s): A. Stothert 19-Oct-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/04/11 20:41:22 $

% CONFIGTRIGGERBLK static method to configure the library trigger block contents
%

try
   blk = strcat(get_param(hBlk,'Parent'),'/',get_param(hBlk,'Name'));
   
   %Determine comparator block settings based on trigger type
   trgType = get_param(hBlk,'TriggerType');
   switch trgType
      case 'rising'
         iconStr = 'disp(''Rising'')';
         relOps = {'>=', '<', '>'};
      case 'falling'
         iconStr = 'disp(''Falling'')';
         relOps = {'<=', '>', '<'};
      case 'either'
         iconStr = 'disp(''Rising or falling'')';
   end
   cBlks = {'/C1','/C2','/C3'};
   for ct = 1:numel(cBlks)
      if ~strcmp(get_param(strcat(blk,cBlks{ct}),'relop'),relOps{ct})
         set_param(strcat(blk,cBlks{ct}),'relop',relOps{ct})
      end
   end
   %Modify the block icon if necessary
   if ~isequal(get_param(hBlk,'MaskDisplay'),iconStr)
      set_param(hBlk,'MaskDisplay',iconStr);
   end
   
   %Check the zero crossing setting for subsystem elements
   zcBlks = find_system(hBlk,'FollowLinks','on','LookUnderMasks','on','MaskType','Compare To Zero');
   zcSetting = get_param(hBlk,'ZeroCross');
   for ct=1:numel(zcBlks)
      if ~strcmp(get_param(zcBlks(ct),'ZeroCross'),zcSetting);
         set_param(zcBlks(ct),'ZeroCross',zcSetting);
      end
   end
   
   %Switch unit delay block for memory blocks (or vice versa) depending on
   %model solver type
   model = bdroot(blk);
   %Find the active config set 
   cfgs  = getConfigSets(model);
   cfg   = [];
   ct    = 1;
   while ct <= numel(cfgs)
      cfg = getConfigSet(model,cfgs{ct});
      if cfg.isActive
         ct = numel(cfgs) + 1;
      else
         ct = ct + 1;
      end
   end
   %Find the config set solver settings
   if isempty(cfg)
      %Happens when called from library
      solverType = 'Variable Step';
      solver     = 'ode45';
   else
      solverType = cfg.getProp('SolverType');
      solver     = cfg.getProp('Solver');
   end
   %Use unit delay block for all fixed step solvers and ode15s and
   %ode113 which don't support memory blocks, see Memory block
   %documentation
   isFixedStep = strcmp(solverType,'Fixed-step');
   isSpecialCont = any(strcmp(solver,{'ode15s','ode113'}));
   if isSpecialCont || isFixedStep
      %Use unit delay block
      delayType = 'UnitDelay';
      delayBlk  = 'built-in/UnitDelay';
      if isSpecialCont
         %Continuous solver, set sample time to continuous value which
         %causes block to behave like a memory block, see Unit Delay block
         %documentation
         blkParam = {'SampleTime', '1'};
      else
         %Discrete solver, inherit sample time
         blkParam = {'SampleTime', '-1'};
      end
   else
      %Use memory block
      delayType = 'Memory';
      delayBlk  = 'built-in/Memory';
      blkParam  = {};
   end
   dBlks = {'/D1', '/D2', '/D3'};
   for ct = 1:numel(dBlks)
      dBlk = strcat(blk,dBlks{ct});
      if ~strcmp(get_param(dBlk,'BlockType'),delayType)
         p = get_param(dBlk,'position');
         delete_block(dBlk);
         add_block(delayBlk,dBlk, 'position', p);
         if ~isempty(blkParam)
            set_param(dBlk,blkParam{1,1},blkParam{1,2});
         end
      end
   end
   
   %Switch the rate conversion block based on solver type
   rcBlk = strcat(blk,'/RateConversion');
   if isFixedStep && strcmp(solver,'FixedStepDiscrete')
      rcType = 'RateTransition';
      rcSrc  = 'built-in/RateTransition';
   else
      rcType = 'Gain';
      rcSrc  = 'built-in/Gain';
   end
   if ~strcmp(get_param(rcBlk,'BlockType'),rcType)
      p = get_param(rcBlk,'position');
      delete_block(rcBlk);
      add_block(rcSrc,rcBlk,'position',p);
   end
   
catch E
   fprintf('**** slctrlblkdlgs.configTriggerBlk: %s\n',E.message)
end
end
 