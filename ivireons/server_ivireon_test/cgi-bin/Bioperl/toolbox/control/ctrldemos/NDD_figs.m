function NDD_figs(fignum)
% Draws feedback loop

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2007/06/07 14:35:08 $

figure;
ax = gca;
switch fignum
   case 1
      % Diagram for "Using FEEDBACK to Close Feedback Loops"
      set(ax,'visible','off','xlim',[-1 21],'ylim',[0 10],'position',[-.1 .2 1.2 .75])
      y0 = 7.2;  x0 = 1.5;
      wire('parent',ax,'x',x0+[0 2],'y',y0+[0 0],'arrow',0.5);
      sumblock('parent',ax,'position',[x0+2.5,y0],'label','-240',...
         'radius',.5,'fontsize',15);
      wire('parent',ax,'x',x0+[3 6],'y',y0+[0 0],'arrow',0.5);
      sysblock('parent',ax,'position',[x0+6 y0-1.5 3 3],'name','G',...
         'fontsize',12+2*isunix,'fontweight','bold','facecolor',[1 1 .9]);
      wire('parent',ax,'x',x0+[9 14],'y',y0+[0 0],'arrow',0.5);
      sysblock('parent',ax,'position',[x0+6 y0-7.5 3 3],'name','K',...
         'fontsize',12+2*isunix,'fontweight','bold','facecolor',[1 1 .9]);
      wire('parent',ax,'x',x0+[12 12 9],'y',y0+[0 -6 -6],'arrow',0.5);
      wire('parent',ax,'x',x0+[6 2.5 2.5],'y',y0+[-6 -6 -0.5],'arrow',0.5);
      text('parent',ax,'position',[x0 y0],'string','r ',...
         'horiz','right','fontsize',12+2*isunix,'fontweight','bold');
      text('parent',ax,'position',[x0+14 y0],'string',' y',...
         'horiz','left','fontsize',12+2*isunix,'fontweight','bold');
      sysblock('parent',ax,'position',[x0+1 y0-8.5 12 11],'num',' ','name',' ',...
         'fontsize',12+2*isunix,'fontweight','bold','facecolor','none',...
         'linestyle',':','linewidth',1,'edgecolor','k');
      equation('parent',ax,'position',[x0+13.5,y0-7],'name','H','num','G','den','1+GK',...
         'anchor','left','fontsize',12+2*isunix,'fontweight','bold')
   case 2
      % Diagram from "Preventing State Duplication in System
      % Interconnections"
      set(ax,'visible','off','xlim',[-2 22],'ylim',[0.3 10.7],'position',[0 .2 1.1 .75])
      y0 = 5;  x0 = 0;
      wire('parent',ax,'x',x0+[0 3],'y',y0+[0 0],'arrow',0.5);
      wire('parent',ax,'x',x0+[0 3],'y',y0+[2 2],'arrow',0.5);
      wire('parent',ax,'x',x0+[0 3],'y',y0+[-2 -2],'arrow',0.5);
      sysblock('parent',ax,'position',[x0+3 y0-3 3 6],'name','G',...
         'fontsize',12+0*isunix,'fontweight','bold','facecolor',[1 1 .9]);
      sysblock('parent',ax,'position',[x0+10 y0+3-2 5 4],'name','Fa','num','s+1','den','s^2+2s+5',...
         'fontsize',12+0*isunix,'fontweight','bold','facecolor',[1 1 .9]);
      sysblock('parent',ax,'position',[x0+10 y0-3-2 5 4],'name','Fb','num','s+2','den','s^2+3s+7',...
         'fontsize',12+0*isunix,'fontweight','bold','facecolor',[1 1 .9]);
      wire('parent',ax,'x',x0+[6 8 8 10],'y',y0+[0 0 3 3],'arrow',0.5);
      wire('parent',ax,'x',x0+[6 8 8 10],'y',y0+[0 0 -3 -3],'arrow',0.5);
      wire('parent',ax,'x',x0+[15 18],'y',y0+[3 3],'arrow',0.5);
      wire('parent',ax,'x',x0+[15 18],'y',y0+[-3 -3],'arrow',0.5);
end