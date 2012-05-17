function kalmdemo_figs()
% Creates pictures for KALMDEMO demo. Save resulting
% figure as PNG file to include in demo.

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2007/06/07 14:35:16 $

figure;
ax = gca;
set(get(ax,'parent'),'position',[360   682   498   242]);
set(ax,'visible','off','xlim',[1 18],'ylim',[4 10])

y0 = 7.2;  x0 = 0.5;
wire('parent',ax,'x',x0+[0 2],'y',y0+[0 0],'arrow',0.5);
sumblock('parent',ax,'position',[x0+2.5,y0],'label','+150',...
    'radius',.5,'fontsize',15);
wire('parent',ax,'x',x0+[3 5],'y',y0+[0 0],'arrow',0.5);
sysblock('parent',ax,'position',[x0+5 y0-1 3 2],'name','Plant',...
    'fontsize',12+2*isunix,'fontweight','bold','facecolor',[1 1 .9]);
wire('parent',ax,'x',x0+[8 10],'y',y0+[0 0],'arrow',0.5);
sumblock('parent',ax,'position',[x0+10.5,y0],'label','+150',...
    'radius',.5,'fontsize',15);
wire('parent',ax,'x',x0+[11 13],'y',y0+[0 0],'arrow',0.5);
sysblock('parent',ax,'position',[x0+13 y0-2.5 3 3],'name','Filter',...
    'fontsize',12+2*isunix,'fontweight','bold','facecolor',[1 1 .9]);

wire('parent',ax,'x',x0+[16,18],'y',y0-1+[0 0],'arrow',0.5);
wire('parent',ax,'x',x0+10.5+[0,0],'y',y0+1.5+[0 -1],'arrow',0.5);
wire('parent',ax,'x',x0+2.5+[0,0],'y',y0+1.5+[0 -1],'arrow',0.5);
wire('parent',ax,'x',x0+[1,13],'y',y0-2+[0 0],'arrow',0.5);
wire('parent',ax,'x',x0+[1,1],'y',y0-2+[0 2]);

text('parent',ax,'position',[x0 y0],'string','u ', 'horiz','right', ...
    'verticalalignment', 'bottom', 'fontsize',12+2*isunix,'fontweight','bold');
text('parent',ax,'position',[x0+10.5 y0+1.5],'string','noise ', 'horiz','center', ...
    'verticalalignment', 'bottom', 'fontsize',12+2*isunix,'fontweight','bold');
text('parent',ax,'position',[x0+2.5 y0+1.5],'string','noise ', 'horiz','center', ...
    'verticalalignment', 'bottom', 'fontsize',12+2*isunix,'fontweight','bold');
text('parent',ax,'position',[x0+18 y0-1],'string',' y\_e', 'horiz','left', ...
    'verticalalignment', 'bottom', 'fontsize',12+2*isunix,'fontweight','bold');
text('parent',ax,'position',[x0+12.5 y0],'string','yv ', 'horiz','right', ...
    'verticalalignment', 'bottom', 'fontsize',12+2*isunix,'fontweight','bold');

