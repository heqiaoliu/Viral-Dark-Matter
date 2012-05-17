function iconStr = configBlk(hBlk) 
 
% Author(s): A. Stothert 08-Oct-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:51:19 $

% CONFIGBLK static method to configure the library block contents
%

blk = hBlk.getFullName;

%Do we need to modify the block icon to indicate the block is disabled?
if strcmp(hBlk.enabled,'off')
   pos = hBlk.Position;
   xX = pos(3)-pos(1);
   xY = pos(4)-pos(2);
   iconStr = sprintf('plot([0 %d],[0 %d],[0 %d],[%d 0]);\n', ...
      xX,xY,xX,xY);
else
   iconStr = '';
end

%Only configure rest of block is simulation is not running
simstatus = get_param(strtok(getFullName(hBlk),'/'),'SimulationStatus');
isRunning = strcmp(simstatus,'running') || strcmp(simstatus, 'paused');
if isRunning
   return
end

%Check whether we need an output port or not
if (strcmp(hBlk.export, 'on'))
   blocktype='Outport';
else
   blocktype='Terminator';
end;
outblk=strcat(blk, '/out');
if (~strcmp(get_param(outblk, 'blocktype'), blocktype))
   p=get_param(outblk, 'position');
   delete_block(outblk);
   add_block(['built-in/', blocktype], outblk, 'position', p);
end;

%Push assertion settings to the assertion block.
asrtblk = strcat(blk,'/Assertion');
props = {...
   'enabled', 'Enabled'; ...
   'stopWhenAssertionFail', 'stopWhenAssertionFail'};
for ct = 1:size(props,1)
   if ~isequal(get_param(asrtblk,props{ct,2}),get_param(blk,props{ct,1}))
      %Need to assert block parameter value
      set_param(asrtblk,props{ct,2},get_param(blk,props{ct,1}));
   end
end
%Make sure shadow object for assertion block is set to parent subsystem
hShadow = get_param(asrtblk,'ShadowObject');
hBlkThis =get_param(blk,'Handle');
if ~isequal(hShadow,hBlkThis)
   set_param(asrtblk,'ShadowObject',hBlkThis);
end

end