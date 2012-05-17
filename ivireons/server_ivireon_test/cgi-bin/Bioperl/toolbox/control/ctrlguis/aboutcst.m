function aboutcst
%ABOUTCST  About Control System Toolbox (splash)

%   Author(s): A. DiVergilio
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.4.4.5 $  $Date: 2008/08/22 20:25:39 $

%---Re-use the figure if its already open
persistent f
if isempty(f) || ~ishghandle(f)
   %---Figure
   fw = 330;
   fh = 420;
   sp = 25;
   f = figure(...
      'Name','About Control System Toolbox',...
      'IntegerHandle','off',...
      'NumberTitle','off',...
      'DoubleBuffer','on',...
      'Color','k',...
      'Units','pixels',...
      'Position',[0 0 fw fh],...
      'MenuBar','none',...
      'Resize','off',...
      'HandleVisibility','callback',...
      'Visible','off', ...
      'Tag', 'AboutCST');
   centerfig(f);
   %---Axes
   axes(...
      'Parent',f,...
      'Units','pixels',...
      'Position',[sp fh-sp-(fw-2*sp) fw-2*sp fw-2*sp],...
      'Units','normalized',...
      'XLim',[-1 1],...
      'YLim',[-1 1],...
      'HitTest','off',...
      'DrawMode','fast',...
      'DefaultLineLineWidth',3,...
      'DefaultLineClipping','off',...
      'DefaultLineHitTest','off',...
      'DefaultTextHitTest','off',...
      'Visible','off');
end
%---Animate
set(f,'Visible','on')
spinlogo(f);

%%%%%%%%%%%%
% spinlogo %
%%%%%%%%%%%%
function spinlogo(f,varargin)
%---Animate CST splash screen

%---Temporarily disable re-animation
set(f,'ButtonDownFcn','','Pointer','watch');

%---Axes handle
a = findobj(get(f,'Children'),'flat','Type','axes');

%---Clean up
delete(findobj(get(f,'children'),'flat','type','uicontrol'))
delete(allchild(a));

%---Create a zgrid
[lh,th] = zpchart(a);

%---Delete the text, make the lines bold
delete(th)
set(lh,'LineWidth',2,'LineStyle','-','Clipping','off')

%---Animate
X = [-90 -82 -69 -55 -40 -25 -5 25 40 55 69 82 90];
C1 = [180 100  30  15  12  10  9  8  7  6  5  4  3];
C2 = [3.5 4.0 4.5  5  5.5  5.8  6 6.1 6.2 6.3 6.4 6.5 6.6];
n = 0;
for x = 1:length(X)
   set(a,'cameraviewangle',C1(x))
   n = n+1;
   set(a,'view',[X(x)+90 -X(x)]);
   set(lh,'color',[abs(X(x)/90) 0 1-abs(X(x)/90)]);
   pause(.01)
end
for x = 1:length(X)-1
   set(a,'cameraviewangle',C2(x))
   n = n+1;
   set(a,'view',[X(length(X)-x)+90 -X(length(X)-x)]);
   set(lh,'color',[abs(X(x)/90) 1-abs(X(x)/90) 0]);
   pause(.01)
end
set(a,'cameraviewangle',6.60861)

%---Add some nice data to plot
z = [-0.1984+0.2129i -0.1984-0.2129i];
p = [ 0.0447+0.4558i 0.0447-0.4558i 0.1848+0.1586i 0.1848-0.1586i -0.3560+0.3916i -0.3560-0.3916i];
% k = 0.5059;
%sys = zpk(z,p,k,1);
%[R,K] = rlocus(sys);
R = ...
   [ 0.04475-0.4558i     0.04475+0.4558i     0.1848-0.1586i     0.1848+0.1586i     -0.356-0.3916i     -0.356+0.3916i ;
   0.04523-0.443i      0.04523+0.443i      0.1844-0.1829i     0.1844+0.1829i    -0.3561-0.3955i    -0.3561+0.3955i ;
   0.04518-0.43i       0.04518+0.43i       0.1846-0.205i      0.1846+0.205i     -0.3562-0.3992i    -0.3562+0.3992i ;
   0.04186-0.4013i     0.04186+0.4013i     0.1883-0.248i      0.1883+0.248i     -0.3567-0.4065i    -0.3567+0.4065i ;
   0.03987-0.3938i     0.03987+0.3938i     0.1905-0.2585i     0.1905+0.2585i    -0.3568-0.4082i    -0.3568+0.4082i ;
   0.0372-0.3862i      0.0372+0.3862i     0.1933-0.2689i     0.1933+0.2689i     -0.357-0.41i       -0.357+0.41i   ;
   0.02965-0.3715i     0.02965+0.3715i     0.2012-0.2888i     0.2012+0.2888i    -0.3573-0.4135i    -0.3573+0.4135i ;
   0.02494-0.365i      0.02494+0.365i      0.2062-0.2978i     0.2062+0.2978i    -0.3575-0.4152i    -0.3575+0.4152i ;
   0.01985-0.359i      0.01985+0.359i      0.2115-0.3061i     0.2115+0.3061i    -0.3578-0.417i     -0.3578+0.417i  ;
   0.009281-0.3491i    0.009281+0.3491i     0.2226-0.3203i     0.2226+0.3203i    -0.3583-0.4205i    -0.3583+0.4205i ;
   -0.0099-0.3356i     -0.0099+0.3356i     0.2429-0.3413i     0.2429+0.3413i    -0.3595-0.4273i    -0.3595+0.4273i ;
   -0.02628-0.3263i    -0.02628+0.3263i     0.2608-0.3572i     0.2608+0.3572i    -0.3609-0.4339i    -0.3609+0.4339i ;
   -0.0519-0.313i      -0.0519+0.313i        0.29-0.3811i       0.29+0.3811i    -0.3646-0.447i     -0.3646+0.447i  ;
   -0.1052-0.2839i     -0.1052+0.2839i     0.3633-0.4391i     0.3633+0.4391i    -0.3846-0.4909i    -0.3846+0.4909i ;
   -0.1289-0.2682i     -0.1289+0.2682i      0.409-0.476i       0.409+0.476i     -0.4067-0.5236i    -0.4067+0.5236i ;
   -0.1426-0.2581i     -0.1426+0.2581i     0.4439-0.5049i     0.4439+0.5049i    -0.4278-0.5498i    -0.4278+0.5498i ;
   -0.1662-0.2395i     -0.1662+0.2395i     0.5349-0.5827i     0.5349+0.5827i    -0.4951-0.6207i    -0.4951+0.6207i ;
   -0.1805-0.2278i     -0.1805+0.2278i      0.639-0.6754i      0.639+0.6754i     -0.585-0.706i      -0.585+0.706i  ;
   -0.1887-0.221i      -0.1887+0.221i      0.7594-0.7859i     0.7594+0.7859i    -0.6972-0.8094i    -0.6972+0.8094i ;
   -0.1984-0.2129i     -0.1984+0.2129i      15.49-15.46i       15.49+15.46i      -15.42-15.46i      -15.42+15.46i  ;
   -0.1984-0.2129i     -0.1984+0.2129i        Inf+0i             Inf+0i             Inf+0i             Inf+0i      ]';
l1 = line('Parent',a,'XData',real(R(1,1)),'YData',imag(R(1,1)),'Color',[0 0.8 0]);
l2 = line('Parent',a,'XData',real(R(2,1)),'YData',imag(R(2,1)),'Color',[0 0.8 0]);
l3 = line('Parent',a,'XData',real(R(3,1)),'YData',imag(R(3,1)),'Color',[0.9 0 0.9]);
l4 = line('Parent',a,'XData',real(R(4,1)),'YData',imag(R(4,1)),'Color',[0.9 0 0.9]);
l5 = line('Parent',a,'XData',real(R(5,1)),'YData',imag(R(5,1)),'Color',[0 0 1]);
l6 = line('Parent',a,'XData',real(R(6,1)),'YData',imag(R(6,1)),'Color',[0 0 1]);
line('Parent',a,'XData',real(p),'YData',imag(p),'Color',[1 1 0],'LineStyle','none','LineWidth',2,'Marker','x','MarkerSize',10);
line('Parent',a,'XData',real(z),'YData',imag(z),'Color',[0 1 1],'LineStyle','none','LineWidth',2,'Marker','o','MarkerSize',8);
for n=2:2:length(R(1,:))
   set(l1,'XData',real(R(1,1:n)),'YData',imag(R(1,1:n)));
   set(l2,'XData',real(R(2,1:n)),'YData',imag(R(2,1:n)));
   set(l3,'XData',real(R(3,1:n)),'YData',imag(R(3,1:n)));
   set(l4,'XData',real(R(4,1:n)),'YData',imag(R(4,1:n)));
   set(l5,'XData',real(R(5,1:n)),'YData',imag(R(5,1:n)));
   set(l6,'XData',real(R(6,1:n)),'YData',imag(R(6,1:n)));
   pause(.01);
end

%---CST info
t = text(...
   'Parent',a,...
   'String','Control System Toolbox',...
   'FontSize',14,...
   'FontWeight','bold',...
   'Color',[0 0 0],...
   'Units','data',...
   'Position',[-.9 -1.3],...
   'Clipping','off', ...
   'Tag', 'ProductNameText');
for x = 1:16
   set(t,'Color',x/16*[1 1 1]);
   pause(.01)
end
ext = get(t,'extent');
verstruct = ver('control');
verstring = sprintf('  V%s',verstruct.Version);
t = text(...
   'Parent',a,...
   'String',verstring,...
   'FontSize',14,...
   'FontWeight','bold',...
   'Color',[1 1 1],...
   'Units','data',...
   'Position',[1.1 -1.3],...
   'Clipping','off', ...
   'Tag', 'VersionText');
xf = ext(1)+ext(3);
dx = 1.1-xf;
for n = 1:5
   set(t,'Position',[1.1-dx*n/5 -1.3]);
   pause(.01)
end
ext = get(t,'extent');
text(...
   'Parent',a,...
   'String',{sprintf('Copyright 1986-%s',verstruct.Date(end-3:end)),'The MathWorks, Inc.'},...
   'FontSize',12,...
   'FontWeight','norm',...
   'VerticalAlignment','top',...
   'Color',[1 1 1],...
   'Units','data',...
   'Position',[-.9 ext(2)-.035],...
   'Clipping','off',...
   'Tag', 'CopyrightText');

%---OK
uicontrol(...
   'Parent',f,...
   'Style','frame',...
   'BackgroundColor',[.6 .6 .6],...
   'Units','norm',...
   'Position',[.74 .02 .24 .08]);
uicontrol(...
   'Parent',f,...
   'Style','pushbutton',...
   'String','OK',...
   'FontWeight','norm',...
   'BackgroundColor',[.1 .1 .1],...
   'ForegroundColor','w',...
   'Callback','close(gcbf)',...
   'Units','norm',...
   'Position',[.76 .03 .2 .06],...
   'Tag','OKButton');

%---Activate lines for re-animation
set(f,'ButtonDownFcn',@spinlogo,'Pointer','arrow');