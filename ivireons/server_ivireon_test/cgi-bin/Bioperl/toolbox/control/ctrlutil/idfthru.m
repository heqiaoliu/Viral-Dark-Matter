function idfthru(blk,Td,u0)
%IDFTHRU  Helper function for Integer Delay with Feedthrough block
%         This function is called during MaskInitialization, and is
%         not intended for command-line usage.
  
% Greg Wolodkin, P. Gahinet
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.6 $  $Date: 2010/04/05 22:13:42 $
if isempty(Td)
   % Sometimes invoked by LTIMASK:UpdateDiagram (find_system call) before
   % Td has been initialized (see g286686)
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
% RE: Scalar expansion done outside. TD and U0 should have the same size at this point
if ~isvector(Td)
   errordlg(sprintf('Invalid setting in block ''%s'' for parameter ''Delay Time''', blk),...
      'Integer Delay Error');
   return
end
N = length(Td);

if ~isvector(u0)
   errordlg(sprintf('Invalid setting in block ''%s'' for parameter ''Initial Input''', blk),...
      'Integer Delay Error');
   return
end
M = length(u0);

if M~=N
   errordlg(sprintf(...
      'Invalid setting in block ''%s'' for parameter ''Initial Input'': Size mismatch between Delay Time', blk),...
      'Integer Delay Error');
   return
end

% Delete mask contents
MaskBlocks = get_param(blk,'Blocks');
for ct=1:length(MaskBlocks)
   name = MaskBlocks{ct};
   if ~any(strcmp(name,{'Inport','Outport'}))
      delete_block([blk '/' name]);
   end
end
lines = get_param(blk,'lines');
for ct=1:length(lines)
   delete_line(lines(ct).Handle);
end

% Load simulink/Discrete library or add_block will fail
open_system('simulink','loadonly');

if all(Td==0)
   % No delay
   add_line(blk,'Inport/1','Outport/1');
   set_param(blk,'MaskDisplay','plot([0 1],[0.5 0.5])',...
      'MaskIconFrame','off','ShowName','off');

elseif N==1
   % Scalar case
   delaypos = [195 36 225 74];
   mv = {'Td' 'Elements as channels (sample based)' 'u0' 'Ts' };
   add_block('simulink/Discrete/Integer Delay',sprintf('%s/Integer Delay',blk),...
      'Position',delaypos,'ShowName','off','MaskValues',mv);
   add_line(blk,'Inport/1','Integer Delay/1');
   add_line(blk,'Integer Delay/1','Outport/1');
   set_param(blk,'ShowName','on')
   
else
   % Mux and demux
   demuxpos = [150 36 155 36+25*N+10];
   muxpos   = [270 36 275 36+25*N+10];
   delaypos = [195 44 225 64];

   add_block('built-in/Demux',[blk '/Demux'],'Position',demuxpos,...
      'BackgroundColor','black','ShowName','off',...
      'Outputs',num2str(N));
   add_block('built-in/Mux',[blk '/Mux'],'Position',muxpos,...
      'DisplayOption','bar','ShowName','off','Inputs',num2str(N))
   add_line(blk,'Inport/1','Demux/1');
   add_line(blk,'Mux/1','Outport/1');

   for ct=1:N
      if Td(ct)==0
         add_line(blk,sprintf('Demux/%d',ct),sprintf('Mux/%d',ct));
      else
         dblk = sprintf('Integer Delay%d',ct);
         mv = {sprintf('Td(%d)',ct) 'Elements as channels (sample based)' sprintf('u0(%d)',ct) 'Ts' };
         add_block('simulink/Discrete/Integer Delay',sprintf('%s/%s',blk,dblk),...
            'Position',delaypos,'ShowName','off','MaskValues',mv);
         add_line(blk,sprintf('Demux/%d',ct),sprintf('%s/1',dblk));
         add_line(blk,sprintf('%s/1',dblk),sprintf('Mux/%d',ct));
      end
      delaypos = delaypos + [0 25 0 25];
   end
   set_param(blk,'MaskDisplay','disp(str)',...
      'MaskIconFrame','on','ShowName','on');
end

