function milldemo_figs(pictnum)
% Generates pictures for MILLDEMO (save as PNG files to 
% regenerate demo pictures)

%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2007/06/07 14:35:22 $

figure;

switch pictnum
   case 1
      % Beam picture
      set(gca,'Position',[0 0 1 1],'ydir','normal')
      set(gca,'xlim',[0 10],'ylim',[0 6],'vis','off')
      sysblock('pos',[4.1 2 1.8 3],'facecolor',[.7 .7 .9])
      sysblock('pos',[3.6 1 2.8 1],'facecolor',[1 1 1])
      sysblock('pos',[3.6 4 2.8 1],'facecolor',[1 1 1])
      sysblock('pos',[2.8 2.5 1.8 1],'facecolor',[1 1 1])
      sysblock('pos',[5.4 2.5 1.8 1],'facecolor',[1 1 1])
      line([3.4 6.6 NaN 3.4 6.6 NaN 3.7 3.7 NaN 6.3 6.3],...
         [1.5 1.5 NaN 4.5 4.5 NaN 2.25 3.75 NaN 2.25 3.75],...
         'linestyle','--','color','k');
      wire('x',[2.5 4.0],'y',[5 4.75],'arrow',.3);
      wire('x',[2.5 3.4],'y',[5 3.1],'arrow',.3);
      text(2.6,5,'rolling cylinders','hor','right','ver','bottom','fontsize',8+2*isunix);
      wire('x',[2.6 4.6],'y',[1.5 2.25],'arrow',.3);
      text(2.7,1.5,'shaped beam','hor','right','ver','top','fontsize',8+2*isunix);
      wire('x',[8 8],'y',[4 5.2],'arrow',.2);
      wire('x',[8 9],'y',[4 4],'arrow',.2);
      text(7.85,5.2,'y','hor','right','ver','middle','fontsize',8+2*isunix);
      text(9,3.9,'x','hor','center','ver','top','fontsize',8+2*isunix);

   case 2
      % Mill stand picture
      set(gca,'Position',[-.1 0 1.2 1],'ydir','normal')
      set(gca,'xlim',[0 10],'ylim',[0 6],'vis','off')
      sysblock('pos',[3.5 .85 3 4.3],'facecolor',[.9 .9 .9],'linewidth',1)
      t = 0:2*pi/128:2*pi;
      x = .5*sin(t);
      y = .5*cos(t);
      patch('XData',5+x,'YData',3.9+y,'linew',3,'edgecolor','k','facecolor','w');
      patch('XData',5+x,'YData',2.6+y,'linew',3,'edgecolor','k','facecolor','w');
      patch('xdata',[2.6 4.5 5 7.6 7.6 5 4.5 2.6 2.6],...
         'ydata',3.25+[-.3 -.3 -.12 -.12 .12 .12 .3 .3 -.3],...
         'zdata',10*ones(1,9),...
         'facecolor',[.7 .7 .9]);
      text(2.6,3.25,'incoming beam  ','hor','right','ver','middle','fontsize',8+2*isunix);
      text(7.6,3.25,'  shaped beam','hor','left','ver','middle','fontsize',8+2*isunix);
      wire('x',[6.7 7.6],'y',[2.8 2.8],'arrow',.2);
      text(7.15,2.6,'x-axis','hor','center','ver','top','fontsize',8+2*isunix);
      x = .8*sin(pi/2-t(20:48));
      y = .8*cos(pi/2-t(20:48));
      wire('XData',5+x,'YData',3.9+y,'linew',1,'color','r','arrow',.22);
      wire('XData',5+x,'YData',2.6-y,'linew',1,'color','r','arrow',.22);
      text(5,1.4,'rolling cylinders','hor','center','ver','middle','fontsize',8+2*isunix);
      text(5,5.3,'Rolling Mill Stand','hor','center','ver','bottom','fontweight','bold','fontsize',8+2*isunix);

   case 3
      % Diagram
      set(gca,'xlim',[0 10],'ylim',[0 6],'vis','off')
      set(gca,'Position',[0.05 .2 1 0.7])
      DrawOpenX;

   case 4
      axis(gca,'normal');
      set(gca,'Position',[0 .2 1 0.7])
      set(gca,'xlim',[0 1],'ylim',[0 1],'visible','off')
      DrawLQGX

   case 5
      axis(gca,'normal');
      set(gca,'Position',[0.1 .2 .85 0.7])
      set(gca,'xlim',[0 1],'ylim',[0 1],'visible','off')
      % Cross-coupling diagram
      DrawCrossCoupling

   case 6
      axis(gca,'normal');
      set(gca,'Position',[0 .2 1 0.7])
      set(gca,'xlim',[0 1],'ylim',[0 1],'visible','off')
      % MIMO LQG loop
      DrawLQGXY

end


%%%%%%%%%%%%%%%%%%%%

function DrawOpenX
% Draws open-loop model
axis equal
ax = gca;
set(ax,'visible','off','xlim',[6 14],'ylim',[-4 10],'ydir','normal')
y0 = 9;  x0 = 0;
if isunix, 
    fw = 'normal'; fs = 10;
else
    fw = 'bold'; fs = 8;
end
wire('x',x0+[0 1.75],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text(x0,y0,'u  ','horiz','right','fontweight',fw);
sysblock('position',[x0+1.75 y0-1 2.5 2],'name','actuator',...
    'num','H(s)','fontweight',fw,'facecolor',[1 1 .9],'fontsize',fs);
sumblock('position',[x0+6,y0-2],'label',{'+45','+315'},'radius',.3,...
    'LabelRadius',1.2,'fontsize',12);
wire('x',x0+[4.25 6 6],'y',y0+[0 0 -1.7],'parent',ax,'arrow',0.5);

wire('x',x0+[0 1.75],'y',y0+[-4 -4],'parent',ax,'arrow',0.5);
text(x0,y0-4,'w_e ','horiz','right','fontweight',fw);
sysblock('position',[x0+1.75 y0-5 2.5 2],'name','eccentricity',...
    'num','Fe(s)','fontweight',fw,'facecolor',[1 1 .9],'fontsize',fs);
wire('x',x0+[4.25 6 6],'y',y0+[-4 -4 -2.3],'parent',ax,'arrow',0.5);

wire('x',x0+[0 1.75],'y',y0+[-8 -8],'parent',ax,'arrow',0.5);
text(x0,y0-8,'w_i  ','horiz','right','fontweight',fw);
sysblock('position',[x0+1.75 y0-9 2.5 2],'name','input thickness',...
    'num','Fi(s)','fontweight',fw,'facecolor',[1 1 .9],'fontsize',fs);
wire('x',x0+[4.25 11.7],'y',y0+[-8 -8],'parent',ax,'arrow',0.5);

sumblock('position',[x0+12,y0-8],'label',{'+45','+235'},'radius',.3,...
    'LabelRadius',1.2,'fontsize',12);
wire('x',x0+[12.3 19],'y',y0+[-8 -8],'parent',ax,'arrow',0.5);
text(x0+19,y0-8,' f','horiz','left','fontweight',fw);
wire('x',x0+[6.3 11.7],'y',y0+[-2 -2],'parent',ax,'arrow',0.5);
sumblock('position',[x0+12,y0-2],'label',{'+135','+235'},'radius',.3,...
    'LabelRadius',1.2,'fontsize',12);
wire('x',x0+[12.3 14.5],'y',y0+[-2 -2],'parent',ax,'arrow',0.5);
sysblock('position',[x0+14.5 y0-3 2 2],'name','gap to force',...
    'num','gx','fontweight',fw,'facecolor',[1 1 .9],'fontsize',fs);
wire('x',x0+[16.5 19],'y',y0+[-2 -2],'parent',ax,'arrow',0.5);
text(x0+19,y0-2,' \delta','horiz','left','fontweight',fw,'fontsize',12);
wire('x',x0+[9 9 12 12],'y',y0+[-2 -5 -5 -7.7],'parent',ax,'arrow',0.5);
wire('x',x0+[8 8 12 12],'y',y0+[-8 -4 -4 -2.3],'parent',ax,'arrow',0.5);
text(x0+9,y0-1.1,'f_1','horiz','center','fontweight',fw,'fontsize',10);
text(x0+9,y0-9,'f_2','horiz','center','fontweight',fw,'fontsize',10);

x0 = 0;
y0 = -3;
text(x0,y0,'u','horiz','left','color','r','fontsize',fs);
text(x0+2,y0,'command','horiz','left','color','r','fontsize',fs);
text(x0,y0-1.6,'w_e','horiz','left','color','r','fontsize',fs);
text(x0+2,y0-1.4,'eccentricity disturb.','horiz','left','color','r','fontsize',fs);
text(x0,y0-3,'w_i','horiz','left','color','r','fontsize',fs);
text(x0+2,y0-2.8,'input thickness disturb.','horiz','left','color','r','fontsize',fs);

x0 = 13;
text(x0,y0-0.5,'\delta','horiz','left','color','r','fontsize',fs);
text(x0+2,y0-0.5,'thickness gap','horiz','left','color','r','fontsize',fs);
text(x0,y0-2,'f','horiz','left','color','r','fontsize',fs);
text(x0+2,y0-2,'rolling force','horiz','left','color','r','fontsize',fs);


function DrawLQGX
% Draws open-loop model
axis equal
ax = gca;
set(ax,'visible','off','xlim',[1 9],'ylim',[0.5 9.5])
y0 = 0;  x0 = 0;
if isunix, 
    fw = 'normal'; fs = 10;
else
    fw = 'bold'; fs = 8;
end
sysblock('position',[x0+3 y0+5 4 4],'name','Plant',...
    'num','Px','fontweight',fw,'facecolor',[1 1 .9],'fontsize',fs);
wire('x',x0+[0 3],'y',y0+[8 8],'parent',ax,'arrow',0.5);
text(x0,y0+8,'w_e  ','horiz','right','fontweight',fw);
wire('x',x0+[0 3],'y',y0+[7 7],'parent',ax,'arrow',0.5);
text(x0,y0+7,'w_i  ','horiz','right','fontweight',fw);
wire('x',x0+[7 10],'y',y0+[7.5 7.5],'parent',ax,'arrow',0.5);
text(x0+10,y0+7.5,'  \delta','horiz','left','fontweight',fw);

sysblock('position',[x0+3.5 y0 3 3],'name','LQG regulator',...
    'num','Regx','fontweight',fw,'facecolor',[.8 1 1],'fontsize',fs);
wire('x',x0+[7 9 9 6.5],'y',y0+[6 6 1.5 1.5],'parent',ax,'arrow',0.5);
wire('x',x0+[3.5 1 1 3],'y',y0+[1.5 1.5 6 6],'parent',ax,'arrow',0.5);
text(x0+.5,y0+3.5,'u','horiz','right','fontweight',fw);
text(x0+9.5,y0+3.5,'f','horiz','left','fontweight',fw);


function DrawCrossCoupling
% Draws cross coupling
axis equal
ax = gca;
set(ax,'visible','off','xlim',[1 33],'ylim',[2.3 20.2])
if isunix, 
    fw = 'normal'; fs = 10;
else
    fw = 'bold'; fs = 8;
end
sysblock('position',[4 0 5 7],'name','y-axis',...
    'fontweight',fw,'facecolor',[1 1 .9],'fontsize',10);
wire('x',[0 4],'y',[1 1],'parent',ax,'arrow',0.5);
text(0,1,'w_{iy}  ','horiz','right','fontweight',fw);
wire('x',[0 4],'y',[3.5 3.5],'parent',ax,'arrow',0.5);
text(0,3.5,'w_{ey}  ','horiz','right','fontweight',fw);
wire('x',[0 4],'y',[6 6],'parent',ax,'arrow',0.5);
text(0,6,'u_y  ','horiz','right','fontweight',fw);

sysblock('position',[4 11 5 7],'name','x-axis',...
    'fontweight',fw,'facecolor',[1 1 .9],'fontsize',10);
wire('x',[0 4],'y',[12 12],'parent',ax,'arrow',0.5);
text(0,12,'w_{ix}  ','horiz','right','fontweight',fw);
wire('x',[0 4],'y',[14.5 14.5],'parent',ax,'arrow',0.5);
text(0,14.5,'w_{ex}  ','horiz','right','fontweight',fw);
wire('x',[0 4],'y',[17 17],'parent',ax,'arrow',0.5);
text(0,17,'u_x  ','horiz','right','fontweight',fw);

wire('x',[9 13.7],'y',[1 1],'parent',ax,'arrow',0.5);
sumblock('position',[14 1],'label',{'+235'},'radius',.3,...
    'LabelRadius',1.2,'fontsize',12);
wire('x',[14.3 32],'y',[1 1],'parent',ax,'arrow',0.5);
text(32,1,'  \delta_y','horiz','left','fontweight',fw);

wire('x',[9 26.7],'y',[6 6],'parent',ax,'arrow',0.5);
sumblock('position',[27 6],'label',{'+135','-315'},'radius',.3,...
    'LabelRadius',1.2,'fontsize',12);
wire('x',[27.3 32],'y',[6 6],'parent',ax,'arrow',0.5);
text(32,6,'  f_y','horiz','left','fontweight',fw);

wire('x',[9 26.7],'y',[12 12],'parent',ax,'arrow',0.5);
sumblock('position',[27 12],'label',{'-45','+235'},'radius',.3,...
    'LabelRadius',1.2,'fontsize',12);
wire('x',[27.3 32],'y',[12 12],'parent',ax,'arrow',0.5);
text(32,12,'  f_x','horiz','left','fontweight',fw);

wire('x',[9 19.7],'y',[17 17],'parent',ax,'arrow',0.5);
sumblock('position',[20 17],'label',{'+135'},'radius',.3,...
    'LabelRadius',1.2,'fontsize',12);
wire('x',[20.3 32],'y',[17 17],'parent',ax,'arrow',0.5);
text(32,17,'  \delta_x','horiz','left','fontweight',fw);

wire('x',[14 14],'y',[12 10.5-.2],'parent',ax,'arrow',0.5,'color','r');
sysblock('position',[12.5 7.5+.2 3 3-.4],'name','gxy',...
    'fontweight',fw,'facecolor',[1 1 .9],'fontsize',10,'edgecolor','r');
wire('x',[14 14],'y',[7.5+.2 3.5+.3],'parent',ax,'arrow',0.5,'color','r');
sysblock('position',[12.5 2+.2 3 1.5+.1],'name','gy',...
    'fontweight',fw,'facecolor',[1 1 .9],'fontsize',fs,'edgecolor','r');
wire('x',[14 14],'y',[2+.2 1.3],'parent',ax,'arrow',0.5,'color','r');
wire('x',[14 27 27],'y',[4.7 4.7 5.7],'parent',ax,'arrow',0.5,'color','r');

wire('x',[20 20],'y',[6 7.5+.2],'parent',ax,'arrow',0.5,'color','r');
sysblock('position',[18.5 7.5+.2 3 3-.4],'name','gyx',...
    'fontweight',fw,'facecolor',[1 1 .9],'fontsize',10,'edgecolor','r');
wire('x',[20 20],'y',[10.5-.2 14.5-.2],'parent',ax,'arrow',0.5,'color','r');
sysblock('position',[18.5 14.5-.2 3 1.5+.1],'name','gx',...
    'fontweight',fw,'facecolor',[1 1 .9],'fontsize',fs,'edgecolor','r');
wire('x',[20 20],'y',[16-.1 16.7],'parent',ax,'arrow',0.5,'color','r');
wire('x',[20 27 27],'y',[13.5-.2 13.5-.2 12.3],'parent',ax,'arrow',0.5,'color','r');

text(17,20.2,'Coupling between x- and y- axes','horiz','center',...
   'fontweight','bold','fontsize',fs+2);


function DrawLQGXY
% Draws open-loop model
axis equal
ax = gca;
set(ax,'visible','off','xlim',[-3 15],'ylim',[-1 12])
y0 = 0;  x0 = 0;
if isunix, 
    fw = 'normal'; fs = 10;
else
    fw = 'bold'; fs = 8;
end
sysblock('position',[x0+3 y0+5 5 7],'name','Two-Axis Model',...
    'num','Pxy','fontweight',fw,'facecolor',[1 1 .9],'fontsize',fs);
wire('x',x0+[-2 3],'y',y0+[11 11],'parent',ax,'arrow',0.5);
text(x0-2,y0+11,'w_{ex}  ','horiz','right','fontweight',fw);
wire('x',x0+[-2 3],'y',y0+[10 10],'parent',ax,'arrow',0.5);
text(x0-2,y0+10,'w_{ix}  ','horiz','right','fontweight',fw);
wire('x',x0+[-2 3],'y',y0+[9 9],'parent',ax,'arrow',0.5);
text(x0-2,y0+9,'w_{ey}  ','horiz','right','fontweight',fw);
wire('x',x0+[-2 3],'y',y0+[8 8],'parent',ax,'arrow',0.5);
text(x0-2,y0+8,'w_{iy}  ','horiz','right','fontweight',fw);
wire('x',x0+[8 13],'y',y0+[10.5 10.5],'parent',ax,'arrow',0.5);
text(x0+13,y0+10.5,'  \delta_x','horiz','left','fontweight',fw);
wire('x',x0+[8 13],'y',y0+[8.5 8.5],'parent',ax,'arrow',0.5);
text(x0+13,y0+8.5,'  \delta_y','horiz','left','fontweight',fw);

sysblock('position',[x0+3.5 y0-2 4 4],'name','MIMO Regulator',...
    'num','Regxy','fontweight',fw,'facecolor',[.8 1 1],'fontsize',fs);
wire('x',x0+[3.5 0 0 3],'y',y0+[0.5 0.5 6 6],'parent',ax,'arrow',0.5);
text(x0,y0+3.5,'  u_y','horiz','left','fontweight',fw);
wire('x',x0+[3.5 -1 -1 3],'y',y0+[-0.5 -0.5 7 7],'parent',ax,'arrow',0.5);
text(x0-1,y0+3.5,'u_x  ','horiz','right','fontweight',fw);

wire('x',x0+[8 11 11 7.5],'y',y0+[6 6 0.5 0.5],'parent',ax,'arrow',0.5);
text(x0+11,y0+3.5,'f_y  ','horiz','right','fontweight',fw);
wire('x',x0+[8 12 12 7.5],'y',y0+[7 7 -0.5 -0.5],'parent',ax,'arrow',0.5);
text(x0+12,y0+3.5,'  f_x','horiz','left','fontweight',fw);
