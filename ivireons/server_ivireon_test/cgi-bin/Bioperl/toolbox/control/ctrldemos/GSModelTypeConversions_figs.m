function GSModelTypeConversions_figs()
% Helper function for GSModelTypeConversions

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/06/07 14:34:58 $


figure;
p = localParameters;
%---Slides
ax = gca;
 
set(ax,'XLim',[1 12],'YLim',[0 11],'Visible','off');
text('Parent',ax,'String','Model Type Conversions','Position',[5 10],...
   'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle');
localConvertDiagram(ax)
     

%%%%%%%%%%%%%%%%%%%
% localParameters %
%%%%%%%%%%%%%%%%%%%
function p_out = localParameters
%---Parameters/systems used in demo
persistent p;
if isempty(p)
    if ispc
        p.fs1 = 8;
        p.fs2 = 10;
        p.fs3 = 12;
    else
        p.fs1 = 10;
        p.fs2 = 12;
        p.fs3 = 14;
    end
    axBorder = 0.09;
    p.axpos1 = [axBorder 0.55 1-axBorder-.04 0.41];
    p.axpos2 = [0 0.45 1 0.55];
    p.fw1 = 'normal';
    p.fw2 = 'bold';
    p.fw3 = 'bold';
    p.as = .05;  %---Arrow size
    p.sbr = .04; %---Sumblock radius
    p.s = tf('s');
    p.cc1 = [1 1 .9];
    p.cc2 = [.9 1 1];
    p.cc3 = [1 .9 1];
    p.cc4 = [.9 1 .9];
    p.cc5 = [.9 .9 1];
    p.cc6 = [1 .9 .9];
    p.ccg = [.4 .4 .4];
end
p_out = p;


%%%%%%%%%%%%%%%%%%%%%%%
% localConvertDiagram %
%%%%%%%%%%%%%%%%%%%%%%%
function localConvertDiagram(ax)
 %---Model Conversion Diagram
  p = localParameters;
  xc = 5;
  yc = 5;
  dx = 4;
  ddx = dx/12;
  dy = 3;
  ddy = dy/10;
  w = 2.4;
  h = 2;
  %---Blocks
   sysblock('Par',ax,'Pos',[xc-dx/2-w yc+dy/2 w h],  'Num','TF', 'FaceColor',p.cc1,'FontSize',p.fs3,'FontWeight',p.fw3);
   sysblock('Par',ax,'Pos',[xc+dx/2 yc+dy/2 w h],    'Num','ZPK','FaceColor',p.cc2,'FontSize',p.fs3,'FontWeight',p.fw3);
   sysblock('Par',ax,'Pos',[xc-dx/2-w yc-dy/2-h w h],'Num','SS', 'FaceColor',p.cc3,'FontSize',p.fs3,'FontWeight',p.fw3);
   sysblock('Par',ax,'Pos',[xc+dx/2 yc-dy/2-h w h],  'Num','FRD','FaceColor',p.cc4,'FontSize',p.fs3,'FontWeight',p.fw3);
  %---Horizontal arrows
   wire('Par',ax,'XData',[xc-dx/2+ddx xc+dx/2-ddx],'YData',[yc+dy/2+h*2/3 yc+dy/2+h*2/3],'Arrow',dx/8,'Color',[.8 0 0])
   wire('Par',ax,'XData',[xc+dx/2-ddx xc-dx/2+ddx],'YData',[yc+dy/2+h*1/3 yc+dy/2+h*1/3],'Arrow',dx/8,'Color',[.8 0 0])
   wire('Par',ax,'XData',[xc-dx/2+ddx xc+dx/2-ddx],'YData',[yc-dy/2-h*1/2 yc-dy/2-h*1/2],'Arrow',dx/8,'Color',[.8 0 0])
  %---Vertical arrows
   wire('Par',ax,'XData',[xc-dx/2-w*2/3 xc-dx/2-w*2/3],'YData',[yc+dy/2-ddy yc-dy/2+ddy],'Arrow',dy/6,'Color',[.8 0 0])
   wire('Par',ax,'XData',[xc-dx/2-w*1/3 xc-dx/2-w*1/3],'YData',[yc-dy/2+ddy yc+dy/2-ddy],'Arrow',dy/6,'Color',[.8 0 0])
   wire('Par',ax,'XData',[xc+dx/2+w*1/2 xc+dx/2+w*1/2],'YData',[yc+dy/2-ddy yc-dy/2+ddy],'Arrow',dy/6,'Color',[.8 0 0])
  %---Diagonal arrows
   wire('Par',ax,'XData',[xc-dx/2+ddx*1 xc+dx/2-ddx],'YData',[yc+dy/2-ddy yc-dy/2+ddy*1],'Arrow',dy/7,'Color',[.8 0 0])
   wire('Par',ax,'XData',[xc-dx/2+ddx*0 xc+dx/2-ddx],'YData',[yc-dy/2+ddy yc+dy/2-ddy*0],'Arrow',dy/7,'Color',[.8 0 0])
   wire('Par',ax,'XData',[xc+dx/2-ddx*0 xc-dx/2+ddx],'YData',[yc+dy/2-ddy yc-dy/2+ddy*0],'Arrow',dy/7,'Color',[.8 0 0])
