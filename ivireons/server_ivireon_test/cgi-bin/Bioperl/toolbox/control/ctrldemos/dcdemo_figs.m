function dcdemo_figs(fignum)
% Creates pictures for DCDEMO demo. Save resulting
% figure as PNG file to include in demo.

%   Authors: A. DiVergilio
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/06/07 14:35:11 $

figure;

switch fignum
   case 1
      %---DC motor image
      %set(gca,'Position',[0.035 0.415 0.725 0.54])
      set(gca,'vis','off')
      %set(gca,'xlim',[.4 10.4],'ylim',[-.15 5.85],'vis','off')
      fs = 10+2*isunix;
      %---Curve parameters
      t = 0:2*pi/128:2*pi;
      x = .3*sin(t);
      y = 1.1*cos(t);
      xh = .3*sin(t(1:(end-1)/2));
      yh = 1.1*cos(t(1:(end-1)/2));
      %---Resistor/Inductor
      resistor('pos',[1.5 5],'size',1.5,'angle',0);
      inductor('pos',[3.25 4.75],'size',1.5,'angle',-90);
      %---Load
      patch('XData',[6.8+x],'YData',[2.25+y],'linewidth',2,'facecolor',[.6 .6 1]);
      patch('XData',[8.3+xh 6.8+xh],'YData',[2.25+yh 2.25-yh],'linewidth',2,'facecolor',[.7 .7 1]);
      text(7.85,2.25,{'Inertial';'Load J'},'FontSize',fs,'FontWeight','b','Ver','middle','Hor','center')
      wire('XData',8.3+2*xh(5:end-5),'YData',2.25+1.5*yh(5:end-5),'linew',1,'color','r','arrow',.3);
      text(8.2,0.65,{'\omega(t)';'Angular velocity'},'FontSize',fs,'Ver','top','Hor','center')
      wire('XData',9.05+2*xh(15:end-15),'YData',2.25-1.5*yh(15:end-15),'linew',1,'color','r','arrow',.3);
      text(9.5,3.7,{'K_{f}\omega(t)';'Viscous';'friction'},'FontSize',fs,'Ver','bottom','Hor','center')
      %---Shaft
      patch('XData',[6.8+xh/4 5.55+xh/4],'YData',[2.25+yh/4 2.25-yh/4],'linewidth',2,'facecolor',[.8 .8 .8]);
      wire('XData',6+xh(15:end-12),'YData',2.25+yh(15:end-12)/1.15,'linew',1,'color','r','arrow',.3);
      text(6.1,1.3,{'\tau(t)';'Torque'},'FontSize',fs,'Ver','top','Hor','center')
      %---DC Motor
      patch('XData',[3.75+x],'YData',[2.25+y],'linewidth',2,'facecolor',[.6 .6 1]);
      patch('XData',[5.55+xh 3.75+xh],'YData',[2.25+yh 2.25-yh],'linewidth',2,'facecolor',[.7 .7 1]);
      text(4.9,2.25,{'DC';'Motor'},'FontSize',fs,'FontWeight','b','Ver','middle','Hor','center')
      %---Wires
      wire('x',[1 3.75 NaN 1 1.5 NaN 3 3.25 3.25 NaN 3.25 3.25 3.75],...
         'y',[1.5 1.5 NaN 5 5 NaN 5 5 4.75 NaN 3.25 3 3])
      %---Ports
      port('x',[1 1 3.25 3.25],'ydata',[1.5 5 1.5 3],'Name','');
      text(1,3.25,{'+';' ';' ';'V_{a}';' ';' ';'-'},'FontSize',fs,'Ver','middle','Hor','right')
      text(3.25,2.25,{'+';'V_{emf}';'-'},'FontSize',fs,'Ver','middle','Hor','right')
      %---Labels
      text(2.25,5.4,'R','FontSize',fs,'Ver','bottom','Hor','center')
      text(3.75,4,'L','FontSize',fs,'Ver','middle','Hor','left')
   case 2
      %set(gca,'Position',[0.085+0.015 0.49 0.65-0.015 0.45])
      % Draw DC motor diagram
      DrawDCM
   case 3
      % Display feedforward structure
      %set(gca,'Position',[0.085+0.015 0.49 0.65-0.015 0.45])
      DrawFF
   case 4
      % Display feedback structure
      %set(gca,'Position',[0.085+0.015 0.49 0.65-0.015 0.45])
      DrawRLOC
   case 5
      % Show LQR feedback structure
      %set(gca,'Position',[0.085+0.015 0.49 0.65-0.015 0.45])
      DrawLQR
end


%------------------- Local Function

function DrawDCM
% Draws DC motor diagram
axis equal
ax = gca;
set(ax,'visible','off','xlim',[0 25],'ylim',[0 14],'ydir','normal')
y0 = 9;  x0 = 0;
if isunix
   fs = 10;
   fw = 'normal';
else
   fs = 10;
   fw = 'bold';
end
wire('x',x0+[0 2],'y',y0+[0 0],'parent',ax,'arrow',0.5);
sumblock('position',[x0+2.5,y0],'label','-240','labelradius',1.5,...
   'parent',ax,'radius',.5,'fontsize',fs+4,'fontweight',fw);
wire('x',x0+[3 4.5],'y',y0+[0 0],'parent',ax,'arrow',0.5);
sysblock('position',[x0+4.5 y0-2 5 4],'name','Armature',...
   'num','K_m','den','Ls + R',...
   'parent',ax,'fontsize',fs,'fontweight',fw,'facecolor',[1 1 .9]);
wire('x',x0+[9.5 11],'y',y0+[0 0],'parent',ax,'arrow',0.5);
sumblock('position',[x0+11.5,y0],'radius',.5,'label',{},...
   'parent',ax);
wire('x',x0+[11.5 11.5],'y',y0+[2.5 0.5],'parent',ax,'arrow',0.5);
wire('x',x0+[12 13.5],'y',y0+[0 0],'parent',ax,'arrow',0.5);
sysblock('position',[x0+13.5 y0-2 5 4],'name','Load',...
   'num','1','den','Js + K_f',...
   'parent',ax,'fontsize',fs,'fontweight',fw,'facecolor',[1 1 .9]);
wire('x',x0+[18.5 22],'y',y0+[0 0],'parent',ax,'arrow',0.5);
wire('x',x0+[20 20 13],'y',y0+[0 -7 -7],'parent',ax,'arrow',0.5);
sysblock('position',[x0+10 y0-8.5 3 3],'name','K_b',...
   'parent',ax,'fontsize',fs,'fontweight',fw,'facecolor',[1 1 .9]);
wire('x',x0+[10 2.5 2.5],'y',y0+[-7 -7 -0.5],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0 y0],'string','V_a ',...
   'horiz','right','fontsize',fs,'fontweight',fw);
text('parent',ax,'pos',[x0+22 y0],'string',' \omega',...
   'horiz','left','fontsize',fs+4,'fontweight',fw);
text('parent',ax,'pos',[x0+11.5 y0+3],'string','T_d',...
   'vertic','bottom','horiz','center','fontsize',fs,'fontweight',fw);
text('parent',ax,'pos',[x0+4 y0-7.5],'string','V_{emf}',...
   'vertic','top','fontsize',fs,'fontweight',fw);


function DrawFF
% Draws feedforward structure
axis equal
ax = gca;
set(ax,'visible','off','xlim',[0 16],'ylim',[0 10],'ydir','normal')
y0 = 7;  x0 = 0;
if isunix
   fs = 10;
   fw = 'normal';
else
   fs = 10;
   fw = 'bold';
end
wire('x',x0+[0 2],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0 y0],'string','\omega_{ref} ',...
   'horiz','right','fontsize',fs+4,'fontweight',fw);
sysblock('position',[x0+2 y0-1.5 3 3],'name','K_{ff}',...
   'parent',ax,'fontsize',fs,'fontweight',fw,'facecolor',[.8 1 1]);
wire('x',x0+[5 10],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+7 y0+0.5],'string','V_a',...
   'vertic','bottom','horiz','left','fontsize',fs,'fontweight',fw);
sysblock('position',[x0+10 y0-3.5 4 5],'name','DCM',...
   'parent',ax,'fontsize',fs,'fontweight',fw,'facecolor',[1 1 .9]);
wire('x',x0+[8 10],'y',y0-[2 2],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+8 y0-2],'string','T_d ',...
   'horiz','right','fontsize',fs,'fontweight',fw);
wire('x',x0+[14 16],'y',y0-[1 1],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+16 y0-1],'string',' \omega',...
   'horiz','left','fontsize',fs+4,'fontweight',fw);
text('parent',ax,'pos',[x0+8 y0-6],'string','Feedforward Control',...
   'horiz','center','fontweight','bold','fontsize',12);


function DrawRLOC
% Draws root locus feddback structure
axis equal
ax = gca;
set(ax,'visible','off','xlim',[-4 18],'ylim',[-1 9])
y0 = 7;  x0 = 0;
if isunix
   fs = 10;
    fw = 'normal';
else
    fs = 10;
    fw = 'bold';
end
wire('x',x0+[-3 -1],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0-3 y0],'string','\omega_{ref} ',...
    'horiz','right','fontsize',fs+4,'fontweight',fw);
sumblock('position',[x0-0.5 y0],'label',{'+140','-240'},'radius',.5,...
    'LabelRadius',1.5,'fontsize',fs+4);
wire('x',x0+[0 2],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+1 y0+0.5],'string','e',...
    'vertic','bottom','horiz','center','fontsize',fs,'fontweight',fw);
sysblock('position',[x0+2 y0-1.5 3 3],'name','C(s)',...
    'num','K','den','s',...
    'parent',ax,'fontsize',fs,'fontweight',fw,'facecolor',[.8 1 1]);
wire('x',x0+[5 9],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+7 y0+0.5],'string','V_a',...
    'vertic','bottom','horiz','center','fontsize',fs,'fontweight',fw);
sysblock('position',[x0+9 y0-3.5 4 5],'name','DCM',...
    'parent',ax,'fontsize',fs,'fontweight',fw,'facecolor',[1 1 .9]);
wire('x',x0+[7.5 9],'y',y0-[2 2],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+7.5 y0-2],'string','T_d ',...
    'horiz','right','fontsize',fs,'fontweight',fw);
wire('x',x0+[13 17],'y',y0-[1 1],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+17 y0-1],'string',' \omega',...
    'horiz','left','fontsize',fs+4,'fontweight',fw);
wire('x',x0+[15 15 -0.5 -0.5],'y',y0+[-1 -5 -5 -0.5],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+6.5 y0-8],'string','Feedback Control',...
    'horiz','center','fontweight','bold','fontsize',12);


function DrawLQR
% Draws root locus feddback structure
axis equal
ax = gca;
set(ax,'visible','off','xlim',[-4 25],'ylim',[-4 9])
y0 = 7;  x0 = 0;
if isunix
    fs = 10;
    fw = 'normal';
else
    fs = 10;
    fw = 'bold';
end
wire('x',x0+[-3 -1],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0-3 y0],'string','\omega_{ref} ',...
    'horiz','right','fontsize',fs+4,'fontweight',fw);
sumblock('position',[x0-0.5,y0],'label',{'+140','-240'},'radius',.5,...
    'parent',ax,'labelradius',1.5,'fontsize',fs+4);
wire('x',x0+[0 2],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+1 y0+0.5],'string','e',...
    'vertic','bottom','horiz','center','fontsize',fs,'fontweight',fw);
sysblock('position',[x0+2 y0-1.5 2.2 3],'name','',...
    'num','1','den','s',...
    'parent',ax,'fontsize',fs,'fontweight',fw,'facecolor',[1 1 .9]);
wire('x',x0+[4.2 7],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+5.6 y0+0.5],'string','q',...
    'vertic','bottom','horiz','center','fontsize',fs,'fontweight',fw);
sysblock('position',[x0+7 y0-3.5 4 5],'name','K_{lqr}',...
    'parent',ax,'fontsize',fs,'fontweight',fw,'facecolor',[.8 1 1]);
wire('x',x0+[11 15],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+13 y0+0.5],'string','V_a',...
    'vertic','bottom','horiz','center','fontsize',fs,'fontweight',fw);
sysblock('position',[x0+15 y0-3.5 4 5],'name','DCM',...
    'parent',ax,'fontsize',fs,'fontweight',fw,'facecolor',[1 1 .9]);
wire('x',x0+[13.5 15],'y',y0-[2 2],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+13.5 y0-2],'string','T_d ',...
    'horiz','right','fontsize',fs,'fontweight',fw);
wire('x',x0+[19 24],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+24 y0],'string',' \omega',...
    'horiz','left','fontsize',fs+4,'fontweight',fw);
wire('x',x0+[19 20.5 20.5 5.5 5.5 7],'y',y0+[-2 -2 -5 -5 -2 -2],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+13 y0-5.5],'string','x=(i,\omega)',...
    'vertic','top','horiz','center','fontsize',fs,'fontweight',fw);
wire('x',x0+[22 22 -0.5 -0.5],'y',y0+[0 -8 -8 -0.5],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+10 y0-11],'string','LQR Control',...
    'horiz','center','fontweight','bold','fontsize',12);
