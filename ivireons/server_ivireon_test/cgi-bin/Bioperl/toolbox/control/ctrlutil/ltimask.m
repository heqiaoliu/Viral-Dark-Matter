function varargout=ltimask(Action,varargin)
%LTIMASK  Manages the callbacks from the LTI Block mask.
%
%  See also CSTBLOCKS, TF, SS, ZPK.

%   Authors: Kevin Kohrt, P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.11 $ $Date: 2009/05/23 07:53:32 $

% Do not put this in mask or it will turn off warnings each time the model 
% is run (hw persists in mask workspace)
hw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>

switch Action,
   case 'Initialize',
      % Used both for initializing and updating after Apply
      % RE: The mask automatically reevaluates its variables sys and IC (x0)
      %     in the proper workspace before this callback is executed
      % [D,Ts,Tdi,Tdo,Tdio,x0,sysname] = ltimask('Initialize',gcb,sys,IC)
      [varargout{1:nargout}] = LocalCheckData(varargin{:}); 

   case 'UpdateDiagram'
      % Update diagram (must be done after Initialize is complete so that all
      % mask variables are instantiated when reconfiguring subsystem)
      Model = bdroot(varargin{1});
      if ~any(strcmp(get_param(Model,'SimulationStatus'),{'initializing','updating','stopped'}))
         % Abort any call during simulation (can be triggered by any change in
         % some parent masked subsystem, see g245496)
         return
      end
      LocalUpdateDiagram(varargin{:}); % CB,D,Ts,Tdio

   case 'MaskLTICallback'
      % Callback from editing LTI system field
      % RE: 1) Only enables/disables the x0 edit field. Do not attempt to run mask
      %        init (would disable Cancel) or reset dialog entries here (must wait
      %        for Apply)
      %     2) Callback name hardwired in block property 'MaskCallbacks'
      CB = varargin{1};
      MaskVal = get_param(CB,'MaskValues');
      try 
         sys = slResolve(MaskVal{1},CB);
      catch  %#ok<CTCH>
         sys = [];
      end
      if isa(sys,'ss')
         set_param(CB,'MaskEnables',{'on';'on'})
      else
         % Do not reset IC=[] when the model is not SS. This makes the block 
         % impossible to use inside a mask (the mask variable name entered
         % in the Initial States field gets cleared whenever sys=[] (bad input)
         % or TF or ZPK
         set_param(CB,'MaskEnables',{'on';'off'})
      end

   case 'InitializeVars',
      %---This is an obsoleted callback from versions 4.0.1,4.1 versions of
      % the LTI block. It is now used to update this blocks to the current
      % LTI block in the cstblocks.mdl library
      %---For now, just warn the user that they need to update their diagram
      msgbox({'Your Simulink model uses an old version of the LTI Block.'; ...
         ''; ...
         'Use the function SLUPDATE to update all LTI Blocks in the '; ...
         'Simulink model.'}, ...
         'LTI Block Warning','replace');

end

%-------------------------------Internal Functions----------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalCheckData %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function [D,Ts,Tdi,Tdo,Tdio,x0,sysname] = LocalCheckData(CB,sys,x0)
% Extracts and validates system data

% D is a 
%  * scalar ssdata object for state-space and SISO TF/ZPK
%  * array of ssdata objects for MIMO TF/ZPK.
% Only D.Delay.IO and D.Delay.Internal are used.
MaskVal = get_param(CB,'MaskValues');
hCB = get_param(CB,'handle');

% Convert double to SS
if isa(sys,'double') && ~isempty(sys)
   sys = ss(sys);
end

% Error checking
if ~isa(sys,'lti'),
   DAStudio.slerror('Control:simulink:LTIMask1',hCB)
elseif isa(sys,'frd')
   % FRDs not supported
   DAStudio.slerror('Control:simulink:LTIMask2',hCB)
elseif ndims(sys)>2,
   % LTI Arrays not supported
   DAStudio.slerror('Control:simulink:LTIMask3',hCB)
elseif isempty(sys)
   DAStudio.slerror('Control:simulink:LTIMask4',hCB)
elseif ~isreal(sys)
   % Simulink does not handle complex systems
   DAStudio.slerror('Control:simulink:LTIMask6',hCB)
end

% Test properness and make explicit
[isProper,sys] = isproper(sys,'explicit');
if ~isProper
   % Simulink does not handle improper systems
   DAStudio.slerror('Control:simulink:LTIMask5',hCB)
end

% Correctly set enable state of IC edit box
% RE: Make sure SET_PARAM never executes during initialization (recursive call -> error)
sysname = MaskVal{1};
if isStateSpace(sys)
   % Validate initial condition
   lx0 = numel(x0);
   if ~isnumeric(x0) || ~isreal(x0)
      DAStudio.slerror('Control:simulink:LTIMask8',hCB)
   elseif lx0>1 && lx0~=order(sys)
      % Wrong length
      DAStudio.slerror('Control:simulink:LTIMask7',hCB)
   end
   x0 = double(x0(:));
else
   % Ignore x0
   x0 = 0;
end

% Construct output D
D = getPrivateData(sys);
Tdi = D.Delay.Input;
Tdo = D.Delay.Output;
Ts = D.Ts;
if isStateSpace(sys)
   % State space
   Tdio = [];
else
   % Convert to state space
   Tdio = D.Delay.IO;
   [ny,nu] = size(Tdio);
   if ny==1 && nu==1
      % SISO case
      D = slss(D);
   else
      % MIMO case: convert each I/O pair to state space
      D0 = D;
      D = ltipack.ssdata.array([ny nu]);
      for j=1:nu
         for i=1:ny
            D(i,j) = slss(getsubsys(D0,i,j));
         end
      end
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalUpdateDiagram %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateDiagram(CB,D,Ts,Tdio)
% Updates configuration under the mask

% Load required libraries
open_system('simulink','loadonly');
open_system('cstextras','loadonly');

% Delete all except I/O blocks
MaskBlocks = get_param(CB,'Blocks');
for ct=1:length(MaskBlocks)
   name = MaskBlocks{ct};
   if ~any(strcmp(name,{'In1','Out1'}))
      delete_block([CB '/' name]);
   end
end
lines = get_param(CB,'lines');
for ct=1:length(lines)
   delete_line(lines(ct).Handle);
end

% Inport
% RE: Positions are [x1 y1 x2 y2] with (0,0) in upper left corner
x0 = 30;
set_param(sprintf('%s/In1',CB),'Position',[x0 100 x0+30 115]);

% Input delays
x0 = 90;
InputDelayPos = [x0 95 x0+30 125];
InputDelayBlock = sprintf('%s/Input Delay',CB);
if Ts==0
   add_block(sprintf('cstextras/Transport Delay\n(masked)'),InputDelayBlock,...
      'Td','Tdi','ShowName','off','Position',InputDelayPos);
else
   add_block(sprintf('cstextras/Integer Delay\n(masked)'),InputDelayBlock,...
      'Td','Tdi','Ts','Ts','ShowName','off','Position',InputDelayPos);   
end
add_line(CB,'In1/1','Input Delay/1');

% Outport
x0 = 590;
set_param(sprintf('%s/Out1',CB),'Position',[x0 100 x0+30 115]);

% Output delays
x0 = 530;
OutputDelayPos = [x0 95 x0+30 125];
OutputDelayBlock = sprintf('%s/Output Delay',CB);
if Ts==0
   add_block(sprintf('cstextras/Transport Delay\n(masked)'),OutputDelayBlock,...
      'Td','Tdo','ShowName','off','Position',OutputDelayPos);
else
   add_block(sprintf('cstextras/Integer Delay\n(masked)'),OutputDelayBlock,...
      'Td','Tdo','Ts','Ts','ShowName','off','Position',OutputDelayPos);   
end
add_line(CB,'Output Delay/1','Out1/1');

% Dynamics
if isempty(Tdio)
   % SS model
   if isempty(D.Delay.Internal)
      % State space model without internal delays
      x0 = 290;  y0 = 95;
      StateSpaceBlock = sprintf('%s/Internal',CB);
      StateSpacePos = [x0 y0 x0+60 y0+30];
      if Ts==0
         add_block('built-in/StateSpace',StateSpaceBlock,...
            'ShowName','off','Position',StateSpacePos,...
            'A','D.a','B','D.b','C','D.c','D','D.d','X0','x0');
      else
         add_block('built-in/DiscreteStateSpace',StateSpaceBlock,...
            'ShowName','off','Position',StateSpacePos,...
            'A','D.a','B','D.b','C','D.c','D','D.d','X0','x0','SampleTime','Ts');
      end
      add_line(CB,'Input Delay/1','Internal/1');
      add_line(CB,'Internal/1','Output Delay/1');
      
   else
      % State space model with internal delays
      nfd = length(D.Delay.Internal);
      [rs,cs] = size(D.d);
      ny = rs-nfd;
      nu = cs-nfd;
      
      % Demux
      x0 = 450;
      DemuxPos = [x0 80 x0+5 140];
      DemuxBlock = sprintf('%s/Demux',CB);
      add_block('built-in/Demux',DemuxBlock,'Outputs',mat2str([ny nfd]),...
         'ShowName','off','Position',DemuxPos);
      add_line(CB,'Demux/1','Output Delay/1');
      
      % Mux
      x0 = 190;
      MuxPos = [x0 80 x0+5 140];
      MuxBlock = sprintf('%s/Mux',CB);
      add_block('built-in/Mux',MuxBlock,'Inputs',mat2str([nu nfd]),...
         'ShowName','off','Position',MuxPos);
      add_line(CB,'Input Delay/1','Mux/1');
      
      % State-space blocks
      x0 = 290;  y0 = 95;
      StateSpaceBlock = sprintf('%s/Internal',CB);
      StateSpacePos = [x0 y0 x0+60 y0+30];
      if Ts==0
         add_block('built-in/StateSpace',StateSpaceBlock,...
            'ShowName','off','Position',StateSpacePos,...
            'A','D.a','B','D.b','C','D.c','D','D.d','X0','x0');
      else
         add_block('built-in/DiscreteStateSpace',StateSpaceBlock,...
            'ShowName','off','Position',StateSpacePos,...
            'A','D.a','B','D.b','C','D.c','D','D.d','X0','x0','SampleTime','Ts');
      end
      add_line(CB,'Mux/1','Internal/1');
      add_line(CB,'Internal/1','Demux/1');
      
      % Internal delays
      x0 = 230;  y0 = 190;
      fDelayBlock = sprintf('%s/Internal Delay',CB);
      fDelayPos = [x0+80 y0 x0+110 y0+30];
      if Ts==0
         add_block(sprintf('cstextras/Transport Delay\n(masked)'),fDelayBlock,...
            'Td','D.Delay.Internal','Position',fDelayPos,...
            'ShowName','off','Orientation','left');
      else
         add_block(sprintf('cstextras/Integer Delay\n(masked)'),fDelayBlock,...
            'Td','D.Delay.Internal','Ts','Ts',...
            'Position',fDelayPos,'ShowName','off','Orientation','left');
      end
      add_line(CB,'Demux/2','Internal Delay/1');
      add_line(CB,'Internal Delay/1','Mux/2');
   end
   
else
   % TF/ZPK converted to state-space
   [ny,nu] = size(D);
   if ny==1 && nu==1
      % SISO case: use name "internal" for state-space block
      % for backward compatibility
      x0 = 220;
      y0 = 95;
      StateSpaceBlock = sprintf('%s/Internal',CB);
      StateSpacePos = [x0 y0 x0+60 y0+30];
      ioDelayBlock = sprintf('%s/IO Delay',CB);
      ioDelayPos = [x0+80 y0 x0+110 y0+30];
      if Ts==0
         add_block('built-in/StateSpace',StateSpaceBlock,...
            'ShowName','off','Position',StateSpacePos,...
            'A','D.a','B','D.b','C','D.c','D','D.d');
         add_block(sprintf('cstextras/Transport Delay\n(masked)'),ioDelayBlock,...
            'Td','Tdio','Position',ioDelayPos,...
            'ShowName','off');
      else
         add_block('built-in/DiscreteStateSpace',StateSpaceBlock,...
            'ShowName','off','Position',StateSpacePos,...
            'A','D.a','B','D.b','C','D.c','D','D.d','SampleTime','Ts');
         add_block(sprintf('cstextras/Integer Delay\n(masked)'),ioDelayBlock,...
            'Td','Tdio','Ts','Ts','Position',ioDelayPos,...
            'ShowName','off');
      end
      add_line(CB,'Input Delay/1','Internal/1');
      add_line(CB,'Internal/1','IO Delay/1');
      add_line(CB,'IO Delay/1','Output Delay/1');

   else
      % Demux
      x0 = 150;
      DemuxPos = [x0 80 x0+5 80+(nu+1)*20];
      DemuxBlock = sprintf('%s/Demux',CB);
      add_block('built-in/Demux',DemuxBlock,'Outputs',num2str(nu),...
         'ShowName','off','Position',DemuxPos);
      add_line(CB,'Input Delay/1','Demux/1');

      % Mux
      x0 = 490;
      MuxPos = [x0 80 x0+5 80+(ny+1)*20];
      MuxBlock = sprintf('%s/Mux',CB);
      add_block('built-in/Mux',MuxBlock,'Inputs',num2str(ny),...
         'ShowName','off','Position',MuxPos);
      add_line(CB,'Mux/1','Output Delay/1');

      % Sum blocks
      x0 = 420;
      y0 = 80;
      h = (nu+1) * 10;
      for ct=1:ny
         SumBlock = sprintf('%s/Sum%d',CB,ct);
         SumPos = [x0 y0 x0+30 y0+h];
         add_block('built-in/Sum',SumBlock,'IconShape','rectangular',...
            'ShowName','off','Position',SumPos,'Inputs',repmat('+',1,nu));
         add_line(CB,sprintf('Sum%d/1',ct),sprintf('Mux/%d',ct));
         y0 = y0 + h + 50;
      end

      % State-space representation of each SISO transfer Hij(s)
      x0 = 220;
      y0 = 50;
      for cty=1:ny
         for ctu=1:nu
            StateSpaceName = sprintf('Internal_%d_%d',cty,ctu);
            StateSpaceBlock = sprintf('%s/%s',CB,StateSpaceName);
            StateSpacePos = [x0 y0 x0+60 y0+30];
            ioDelayName = sprintf('IO Delay_%d_%d',cty,ctu);
            ioDelayBlock = sprintf('%s/%s',CB,ioDelayName);
            ioDelayPos = [x0+80 y0 x0+110 y0+30];
            if Ts==0
               add_block('built-in/StateSpace',StateSpaceBlock,...
                  'ShowName','off','Position',StateSpacePos,...
                  'A',sprintf('D(%d,%d).a',cty,ctu),...
                  'B',sprintf('D(%d,%d).b',cty,ctu),...
                  'C',sprintf('D(%d,%d).c',cty,ctu),...
                  'D',sprintf('D(%d,%d).d',cty,ctu));
               add_block(sprintf('cstextras/Transport Delay\n(masked)'),ioDelayBlock,...
                  'Td',sprintf('Tdio(%d,%d)',cty,ctu),...
                  'Position',ioDelayPos,...
                  'ShowName','off');
            else
               add_block('built-in/DiscreteStateSpace',StateSpaceBlock,...
                  'ShowName','off','Position',StateSpacePos,...
                  'A',sprintf('D(%d,%d).a',cty,ctu),...
                  'B',sprintf('D(%d,%d).b',cty,ctu),...
                  'C',sprintf('D(%d,%d).c',cty,ctu),...
                  'D',sprintf('D(%d,%d).d',cty,ctu),...
                  'SampleTime','Ts');
               add_block(sprintf('cstextras/Integer Delay\n(masked)'),ioDelayBlock,...
                  'Td',sprintf('Tdio(%d,%d)',cty,ctu),...
                  'Ts','Ts',...
                  'Position',ioDelayPos,...
                  'ShowName','off');
            end
            add_line(CB,sprintf('Demux/%d',ctu),sprintf('%s/1',StateSpaceName));
            add_line(CB,sprintf('%s/1',StateSpaceName),sprintf('%s/1',ioDelayName));
            add_line(CB,sprintf('%s/1',ioDelayName),sprintf('Sum%d/%d',cty,ctu));
            y0 = y0 + 50;
         end
      end
   end
   
end
