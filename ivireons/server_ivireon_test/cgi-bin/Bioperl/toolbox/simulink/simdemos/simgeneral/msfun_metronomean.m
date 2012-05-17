function [sys,x0,str,ts] = msfun_metronomean(t,x,u,flag, sampleTime)
%METRONOMANIMATION S-function for making metronomean animation.
%
%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $
% Plots every major integration step, but has no states of its own 
% 

% Plots every major integration step, but has no states of its own
switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts, simStateCompliance] = mdlInitializeSizes(sampleTime); %#ok<*NASGU>

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2,
    sys=mdlUpdate(t,x,u);

  %%%%%%%%%%%%%%%%
  % Unused flags %
  %%%%%%%%%%%%%%%%
  case { 1, 3, 4, 9 },
    sys = [];
    
  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);
end

% end metronomean

%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
function [sys,x0,str,ts, simStateCompliance]=mdlInitializeSizes(sampleTime)
%
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
%
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 0;
sizes.NumInputs      = 4;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;
sys = simsizes(sizes);

%
% initialize the initial conditions
%
x0  = [];

%
% str is always an empty matrix
%
str = [];

%
% initialize the array of sample times, for the pendulum demo,
% the animation is updated every 0.1 seconds
%
ts  = [sampleTime 0];

%
% create the figure, if necessary
%
LocalMetronomeInit;

% specify that the simState for this s-function is same as the default
simStateCompliance = 'DefaultSimState';

% end mdlInitializeSizes 

%=============================================================================
% mdlUpdate
% Update the pendulum animation.
%=============================================================================
function sys=mdlUpdate(t,x,u) %#ok<*INUSL>

fig = get_param(gcbh, 'UserData');
if ishandle(fig),
  if strcmp(get(fig,'Visible'),'on'),
    ud = get(fig,'UserData');
    LocalMetronomeSets(t,ud,u);
  end
end;

sys = [];
% end mdlUpdate

%=============================================================================
% LocalMetronomeSets
% Local function to set the position of the graphics objects in the
% inverted pendulum animation window.
% The geometric length of the pendulum is 10. 
%=============================================================================
function LocalMetronomeSets(time,ud, u)

u = u([1 2 3 4]);
u(1) = u(1)*10;               % scaling the x 
XDelta   = 15;
PDelta   = 7;                 % Horizontal distance among pendulum  
                                
X1PendTop = u(1) + 10*sin(u(2))  -  PDelta*2;
Y1PendTop = -10*cos(u(2));

X2PendTop = u(1) + 10*sin(u(3)); 
Y2PendTop = -10*cos(u(3));
 
X3PendTop = u(1) + 10*sin(u(4)) + PDelta*2;
Y3PendTop = -10*cos(u(3));

set(ud.Cart,...
  'XData',ones(2,1)*[u(1)-XDelta u(1)+XDelta]);
set(ud.Pend1,...
    'XData',[u(1)-PDelta*2,X1PendTop],...
    'YData',[1,Y1PendTop]);
set(ud.Pend2,...
    'XData',[u(1), X2PendTop],...
    'YData',[1,Y2PendTop]);
set(ud.Pend3,...
    'XData',[u(1) + PDelta*2,X3PendTop],...
    'YData',[1,Y3PendTop]);

set(ud.Head1,...
    'XData',X1PendTop,...
    'YData',Y1PendTop);
set(ud.Head2,...
    'XData',X2PendTop,...
    'YData',Y2PendTop);
set(ud.Head3,...
    'XData',X3PendTop,...
    'YData',Y3PendTop);
 
set(ud.TimeField,...
  'String',num2str(time));

% Force plot to be drawn
%pause(0.1);
drawnow;
% end LocalPendSets

%
%=============================================================================
% LocalMetronomeInit
% Local function to initialize the pendulum animation.  If the animation
% window already exists, it is brought to the front.  Otherwise, a new
% figure window is created.
%=============================================================================
function LocalMetronomeInit
close all;
TimeClock = 0;
XCart     = 0;
Theta     = 0;
XDelta    = 15;
PDelta    = 7;
XPendTop  = XCart + 10*sin(Theta); 
YPendTop  = -10*cos(Theta);
%
% The animation figure handle is stored in the pendulum block's UserData.
% If it exists, initialize the reference mark, time, cart, and pendulum
% positions/strings/etc.
%
Fig = get_param(gcbh,'UserData');

if ishandle(Fig),
  FigUD = get(Fig,'UserData');
  set(FigUD.TimeField,...
      'String',num2str(TimeClock));
  set(FigUD.Cart,...
      'XData',ones(2,1)*[XCart-XDelta XCart+XDelta]);  
  
  % bring it to the front
  figure(Fig);
  return
end
%
% the animation figure doesn't exist, create a new one and store its
% handle in the animation block's UserData
%
FigureName = 'Metronomes Visualization';

Fig = figure(...
  'Units',           'pixel',...
  'Position',        [100 100 500 300],...
  'Name',            FigureName,...
  'NumberTitle',     'off',...
  'IntegerHandle',   'off',...
  'Resize',          'on');
set(Fig, 'MenuBar', 'none');
AxesH = axes(...
  'Parent',  Fig,...
  'Units',   'pixel',...
  'Position',[50 50 400 200],...
  'CLim',    [1 64], ...
  'Xlim',    [-22 22],...
  'Ylim',    [-10 2],...
  'Visible', 'off');

Cart = surface(...
  'Parent',   AxesH,...
  'XData',    ones(2,1)*[XCart-XDelta XCart+XDelta],...
  'YData',    [0 0; 2 2],...
  'ZData',    zeros(2),...
  'CData',    ones(2),...
  'EraseMode','xor');

line([-20,20],[0,0],'linewidth',3);

Pend1 = line([XCart-PDelta*2,XPendTop],[1,YPendTop],'color','b',...
    'linestyle','-','linewidth',2,'erasemode','xor');
Pend2 = line([XCart,XPendTop-PDelta*2],[1,YPendTop],...
    'color','b','linestyle','-','linewidth',2,'erasemode','xor');
Pend3 = line([XCart+PDelta*2,XPendTop+PDelta*2],[1,YPendTop],...
    'color','b','linestyle','-','linewidth',2,'erasemode','xor');

Head1 = line(XPendTop-PDelta*2,YPendTop,'color','y','Marker','.','erasemode','xor','markersize',40);
Head2 = line(XPendTop,YPendTop,'color','m','Marker','.','erasemode','xor','markersize',40);
Head3 = line(XPendTop+PDelta*2,YPendTop,'color','c','Marker','.','erasemode','xor','markersize',40);

uicontrol(...
  'Parent',             Fig,...
  'Style',              'text',...
  'Units',              'pixel',...
  'Position',           [150 0 100 25], ...
  'HorizontalAlignment','right',...
  'String',             'Time: ');

TimeField = uicontrol(...
  'Parent',             Fig,...
  'Style',              'text',...
  'Units',              'pixel', ...
  'Position',           [250 0 100 25],...
  'HorizontalAlignment','left',...
  'String',             num2str(TimeClock));
 
FigUD.Cart         = Cart;
FigUD.Pend1        = Pend1;
FigUD.Pend2        = Pend2;
FigUD.Pend3        = Pend3;
FigUD.TimeField    = TimeField;
FigUD.Head1        = Head1;
FigUD.Head2        = Head2;
FigUD.Head3        = Head3;

axis equal
FigUD.Block        = get_param(gcbh,'Handle');
set(Fig,'UserData',FigUD);
drawnow
% store the figure handle in the animation block's UserData
set_param(gcbh,'UserData',Fig);
% end LocalPendInit
