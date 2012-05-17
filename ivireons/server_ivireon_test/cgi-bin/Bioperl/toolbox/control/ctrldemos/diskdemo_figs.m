function diskdemo_figs(slidenum)
% Creates pictures for DISKDEMO demo. Save resulting
% figure as PNG file to include in demo.

%   Author: P. Gahinet 8/2000
%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2007/06/07 14:35:15 $

% Acknowledgment: The model and data for this demo are taken from Chapter 14
% of "Digital Control of Dynamic Systems," by Franklin, Powell, and Workman.

figure;

switch slidenum
   case 1
      % Disk drive picture
      set(gca,'visible','on', ...
         'XTick',[],'YTick',[],'box','on','Ylim',[.1 1.1],'Xlim',[0 1])
      axis square, hold on
      dskwheel(.5,.6,.3);
      dskwheel(0.2109,0.2670,0.05);
      x=[0.2487,0.5563,0.5685,0.2701,0.2518]-0.05;
      y=[0.2853,0.3980,0.3736,0.2457,0.2853];
      fill(x,y,'w');
      plot(0.5,0.5,'k.','MarkerSize',20);
      title('Disk Platen - Read/Write Head');


   case 2
      cla
      set(gca,'xlim',[0 1],'ylim',[0 1],'vis','off','ydir','normal')
      LocalDrawLoop

end

%---------------------- Local Functions -----------------------------------


function LocalDrawLoop
% Draws control loop
axis equal
ax = gca;
set(ax,'visible','off','xlim',[-1 18],'ylim',[0 12])
y0 = 7;  x0 = 0;
if isunix, 
    fw = 'normal';
else
    fw = 'bold';
end
wire('x',x0+[0 2],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text(x0,y0,'d ','horiz','right','fontweight',fw);
sumblock('position',[x0+2.5,y0],'label','-235','radius',.5,'fontsize',15);
wire('x',x0+[3 7],'y',y0+[0 0],'parent',ax,'arrow',0.5);
sysblock('position',[x0+7 y0-2 4 4],'name','G(s)',...
    'fontweight','bold','facecolor',[1 1 .9],'fontsize',12+2*isunix);
wire('x',x0+[11 16],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text(x0+16,y0,' PES','horiz','left','fontweight',fw);
wire('x',x0+[14 14 13],'y',y0+[0 -6 -6],'parent',ax);
wire('x',x0+[13 13-.707],'y',y0+[-6 -6+.707],'parent',ax);
wire('x',x0+[12 10.5],'y',y0+[-6 -6],'parent',ax,'arrow',0.5);
sysblock('position',[x0+7.5 y0-7.5 3 3],'name','C(z)',...
    'fontweight','bold','facecolor',[.8 1 1],'fontsize',12+2*isunix);
text(x0+12.5,y0-7,'Ts','horiz','center','fontweight',fw);
wire('x',x0+[7.5 6],'y',y0+[-6 -6],'parent',ax,'arrow',0.5);
sysblock('position',[x0+4 y0-7 2 2],'name','ZOH',...
    'fontweight','bold','facecolor',[1 1 .9],'fontsize',8+2*isunix);
wire('x',x0+[4 2.5 2.5],'y',y0+[-6 -6 -0.5],'parent',ax,'arrow',0.5);

text(-2,11.5,'Digital Servo Loop','horiz','left','fontweight','bold','fontsize',14)
