function iconStr = configBlk(hBlk) 
 
% Author(s): A. Stothert 08-Oct-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:56:32 $

% CONFIGBLK static method to configure the library block contents
%

simstatus = get_param(strtok(getFullName(hBlk),'/'),'SimulationStatus');
isRunning = strcmp(simstatus,'running') || strcmp(simstatus, 'paused');
if isRunning
   %Only do block configuration if simulation is not running
   iconStr = '';
   return
end

blk = hBlk.getFullName;
%Check the type of source and edge detection block we need.
if strcmp(hBlk.LinearizeAt,'ExternalTrigger')
   srcBlkType = 'built-in/Inport';
   trgBlkType = hBlk.TriggerType;
else
   srcBlkType = 'slctrlextras/Snapshot trigger signal';
   trgBlkType = 'rising';
end
%Change the edge detection settings if needed
cBlk = strcat(blk,'/Detect edge');
if ~strcmp(trgBlkType,get_param(cBlk,'TriggerType'))
   set_param(cBlk,'TriggerType',hBlk.TriggerType);
end
%Set the trigger block ZeroCross setting
if ~strcmp(hBlk.ZeroCross,get_param(cBlk,'ZeroCross'))
   set_param(cBlk,'ZeroCross',hBlk.ZeroCross); 
end
%Change the source block if needed
cBlk = strcat(blk,'/Trigger signal');
refBlk = get_param(cBlk,'referenceblock');
if isempty(refBlk)
   %Built-in blocks do not have a reference block, use block type instead
   refBlk = strcat('built-in/',get_param(cBlk,'blocktype'));
end
if ~strcmp(refBlk,srcBlkType)
   %Need to replace the source block
   p = get_param(cBlk,'position');
   delete_block(cBlk);
   add_block(srcBlkType,cBlk, 'position', p);
end

%Get icon details for the block
iconStr = localDrawIcon(hBlk);
end

function iconStr = localDrawIcon(hBlk)

%Get constants useful for drawing port icons
pos    = hBlk.Position;
ort    = hBlk.Orientation;
hPorts = hBlk.PortHandles;

%Add block icon detail for output port
if strcmp(hBlk.export,'on')
   %Construct basic coordinate (in pixel units) for output port
   zX = [3 0 3 0, nan, 4 5, nan, 7 7];
   zY = [0 0 3 3, nan, 5 5, nan, 6 4];
   
   %Determine offset for output port icon
   portpos = get(hPorts.Outport,'Position');
   switch ort
      case 'right'
         shiftx = portpos(1) - pos(1) - 15;
         shifty = portpos(2) - pos(2) - 2;
      case 'down'
         shiftx = pos(3) - portpos(1) - 2;
         shifty = portpos(2) - pos(4) - 2;
      case 'left'
         shiftx = pos(1) - portpos(1) - 2;
         shifty = pos(4) - portpos(2) - 1;
      case 'up'
         shiftx = pos(3) - portpos(1) -2;
         shifty = pos(4) - portpos(2) -15 ;
   end
   zX = zX + shiftx;
   zY = zY + shifty;
   
   %Construct string to draw output port icon
   iconStr = sprintf('plot(%s,%s);\n',mat2str(zX),mat2str(zY));
else 
   iconStr = '';
end

%Add block icon detail for trigger port
if strcmp(hBlk.LinearizeAt,'ExternalTrigger')
   %Construct basic coordinates (in pixel units) for trigger icon
   switch hBlk.TriggerType
      case 'rising'
         tX = [0 4 4 7 nan 1 4 6];
         tY = [0 0 8 8 nan 3 6 3];
      case 'falling'
         tX = [0 4 4 7 nan 1 4 6];
         tY = [8 8 0 0 nan 6 3 6];
      case 'either'
         tX = [[0 4 4 7 nan 1 4 6], nan, 8 + [0 4 4 7 nan 1 4 6]];
         tY = [[0 0 8 8 nan 3 6 3], nan, [8 8 0 0 nan 6 3 6]];
   end
   
   %Determine offset for trigger icon, based on port location
   portpos = get(hPorts.Inport,'Position');
   switch ort
      case 'right'
         shifty = pos(4) - portpos(2) - 4;
         shiftx = pos(1) - portpos(1) - 3;
      case 'down'
         shifty = pos(4) - portpos(2) - 17;
         shiftx = portpos(1) - pos(1) - 6;
      case 'left'
         shifty = pos(4) - portpos(2) - 4;
         shiftx = portpos(1) - pos(1) - 22;
      case 'up'
         shifty = portpos(2) - pos(4) - 2;
         shiftx = portpos(1) - pos(1) - 6;
      otherwise
         shiftx = [];
         shifty = [];
   end
   tX = tX + shiftx;
   tY = tY + shifty;
   
   %Construct string to draw trigger icon
   iconStr = sprintf('%splot(%s,%s);\n',iconStr,mat2str(tX),mat2str(tY));
end
end
