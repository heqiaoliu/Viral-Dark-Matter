function tdfthru(blk,Td,u0,bufsize)
%TDFTHRU  Helper function for Transport Delay with Feedthrough block
%         This function is called during MaskInitialization, and is
%         not intended for command-line usage.
  
% Greg Wolodkin 10-12-1998
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.12.4.5 $  $Date: 2009/01/20 15:29:30 $
if isempty(Td)
   % When invoked by LTIMASK:UpdateDiagram (find_system) before cleanup, 
   % Tdio may evaluate to empty if the previous model was TF but 
   % the new model is SS (Tdio=[]). Skip call since block is about
   % to be deleted (see g286686)
   return
end

% Do not reconstruct if we are in simulation
Model = bdroot(blk);
if ~any(strcmp(get_param(Model,'SimulationStatus'),{'initializing','updating','stopped'}))
    % Abort any call during simulation (can be triggered by any change in
    % some parent masked subsystem, see g245496)
    return
end

% Validate data
if ~isvector(Td)
   errordlg(sprintf('Invalid setting in block ''%s'' for parameter ''Delay Time''', blk),...
      'Transport Delay Error');
   return
end
N = length(Td);

if ~isvector(u0)
   errordlg(sprintf('Invalid setting in block ''%s'' for parameter ''Initial Input''', blk),...
      'Transport Delay Error');
   return
end
M = length(u0);

if M~=N
   errordlg(sprintf(...
      'Invalid setting in block ''%s'' for parameter ''Initial Input'': Size mismatch between Delay Time', blk),...
      'Transport Delay Error');
   return
end
P = max(M,N);
must_split = (P>1) && any(Td == 0) && any(Td ~= 0);

% Delete contents
InPort = sprintf('%s/Inport',blk);
OutPort = sprintf('%s/Outport',blk);
Exclude = get_param({blk;InPort;OutPort},'Handle');
blocks = setdiff(find_system(blk,'FollowLinks','on',...
   'LookUnderMasks','on','FindAll','on','SearchDepth',1,'Type','block'),cat(1,Exclude{:}));
for ct=1:length(blocks)
   delete_block(blocks(ct));
end
lines = get_param(blk,'lines');
for ct=1:length(lines)
   delete_line(lines(ct).Handle);
end

% Regenerate mask contents
iselpos  = [ 85 36 120 74];
demuxpos = [150 36 155 74];
muxpos   = [270 36 275 74];
oselpos  = [305 36 340 74];

if must_split
   % Vector of delays, some zero
   Td = reshape(Td,[1 N]);
   iz = find(Td == 0);		% those with zero delay
   inz = find(Td ~= 0);
   inx = [iz inz];		% permutation puts zero delay at the top
   [junk,outx] = sort(inx);	% inverse permutation

   delaypos = [195 50 225 80];
   add_block('built-in/Selector',[blk '/ISelect'],'Position',iselpos,...
      'Elements',mat2str(inx),'InputPortWidth',int2str(P));
   add_block('built-in/Demux',[blk '/Demux'],'Position',demuxpos,...
      'BackgroundColor','black','ShowName','off',...
      'Outputs',mat2str([length(iz) length(inz)]));
   add_block('built-in/Transport Delay',...
      [blk '/Transport Delay'],'Position',delaypos);
   add_block('built-in/Mux',[blk '/Mux'],'Position',muxpos,...
      'DisplayOption','bar','ShowName','off','Inputs','2')
   add_block('built-in/Selector',[blk '/OSelect'],'Position',oselpos,...
      'Elements',mat2str(outx),'InputPortWidth',int2str(P));
   add_line(blk,'Inport/1','ISelect/1');
   add_line(blk,'ISelect/1','Demux/1');
   add_line(blk,'Demux/1','Mux/1');
   add_line(blk,'Demux/2','Transport Delay/1');
   add_line(blk,'Transport Delay/1','Mux/2');
   add_line(blk,'Mux/1','OSelect/1');
   add_line(blk,'OSelect/1','Outport/1');

   set_param([blk '/Transport Delay'],'DelayTime',mat2str(Td(inz)),...
      'InitialInput',mat2str(u0(inz)),'BufferSize',int2str(bufsize));
   set_param(blk,'MaskDisplay','block_icon(''Transport Delay'')');
   set_param(blk,'ShowName','on');
   
elseif Td == 0
   % Single delay of zero or vector of zeros
   add_line(blk,'Inport/1','Outport/1');
   set_param(blk,'MaskDisplay','plot([0 1],[0.5 0.5])');
   set_param(blk,'ShowName','off');
   
else
   % Single (or vectorized with no zeros) delay
   delaypos = [195 40 225 70];
   add_block('built-in/Transport Delay',[blk '/Transport Delay'],...
      'Position',delaypos);
   add_line(blk,'Inport/1','Transport Delay/1');
   add_line(blk,'Transport Delay/1','Outport/1');
   set_param([blk '/Transport Delay'],'DelayTime',mat2str(Td),...
      'InitialInput',mat2str(u0),'BufferSize',int2str(bufsize));
   set_param(blk,'MaskDisplay','block_icon(''Transport Delay'')');
   set_param(blk,'ShowName','on');
end
