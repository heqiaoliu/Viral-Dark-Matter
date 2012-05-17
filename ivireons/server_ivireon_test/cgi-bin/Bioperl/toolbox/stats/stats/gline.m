function h = gline(fig)
%GLINE Draw a line in a figure interactively.
%   GLINE(FIG) draws a line segment by clicking the mouse at the
%   two end-points of the line segment in the figure FIG.
%   A rubberband line tracks the mouse movement. 
%   H = GLINE(FIG) Returns the handle to the line.
%
%   GLINE with no input arguments draws in the current figure.

%   Copyright 1993-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:14:18 $

if nargin<1, 
  draw_fig = gcf;
  fig = draw_fig;
end

if ischar(fig), 
   s = fig;
   draw_fig = gcbf;
   ud = get(draw_fig,'UserData');
else
   s = 'start';
   draw_fig = fig; 
end

ax = get(draw_fig,'CurrentAxes');
if isempty(ax)
   ax = axes('Parent',draw_fig);
end

gcacolor = get(ax,'Color');

switch s
   case 'start'
   oldtag = get(draw_fig,'Tag');
   figure(draw_fig);
   if any(get(ax,'view')~=[0 90]), 
     set(draw_fig, 'Tag', oldtag);
     error('stats:gline:NotTwoDimensional','GLINE works only for 2-D plots.');
   end
   
   % Can't do this if another mouse mode is active
   hManager = uigetmodemanager(draw_fig);
   if (~isempty(hManager.CurrentMode))
       error('stats:gline:ModeActive',...
             'Cannot use GLINE while the mouse mode ''%s'' is active.',...
             get(hManager.CurrentMode,'name'))
   end
   
   % Create an invisible line to preallocate the xor line color.
   xlimits = get(ax,'Xlim');
   x = (xlimits + flipud(xlimits))./2;
   ylimits = get(ax,'Ylim');
   y = (ylimits + flipud(ylimits))./2;
   hline = line(x,y,'Parent',ax,'Visible','off');

   bdown = get(draw_fig,'WindowButtonDownFcn');
   bup = get(draw_fig,'WindowButtonUpFcn');
   bmotion = get(draw_fig,'WindowButtonMotionFcn');
   oldud = get(draw_fig,'UserData');
   set(draw_fig,'WindowButtonDownFcn','gline(''down'')')
   set(draw_fig,'WindowButtonMotionFcn','gline(''motion'')')
   set(draw_fig,'WindowButtonupFcn','')
 
   ud.hline = hline;
   ud.pts = [];
   ud.buttonfcn = {bdown; bup; bmotion};
   ud.oldud = oldud;
   ud.oldtag = oldtag;
   set(draw_fig,'UserData',ud);
   if nargout == 1
      h = hline;
   end

case 'motion'
   set(draw_fig,'Pointer','crosshair');

   if isempty(ud.pts);
      return;
   end

   set(ud.hline,'Xdata',ud.pts(:,1),'Ydata',ud.pts(:,2), ...
        'linestyle','-', 'linewidth', 1.5, 'Color',1-gcacolor,'Visible','on');
   Pt2 = get(ax,'CurrentPoint'); 
   Pt2 = Pt2(1,1:2);    
   ud.pts(2,:) = Pt2;

   set(draw_fig,'UserData',ud);

case 'down'   
   Pt1 = get(ax,'CurrentPoint'); 
   ud.pts = [Pt1(1,1:2); Pt1(1,1:2)];
   set(ud.hline,'Xdata',ud.pts(:,1),'Ydata',ud.pts(:,2), ...
        'linestyle','-', 'linewidth', 1.5, 'Color',1-gcacolor,'Visible','on');

   set(draw_fig,'WindowButtonDownFcn','gline(''down2'')','UserData',ud)
   
case 'down2'
   Pt2 = get(ax,'CurrentPoint'); Pt2 = Pt2(1,1:2);    
   ud.pts(2,:) = Pt2;
   set(ud.hline,'Xdata',ud.pts(:,1),'Ydata',ud.pts(:,2), ...
         'linestyle','-', 'linewidth', 1.5, 'Color',1-gcacolor);

   bfcns = ud.buttonfcn;
   set(draw_fig,'windowbuttondownfcn',bfcns{1},'windowbuttonupfcn',bfcns{2}, ...
         'windowbuttonmotionfcn',bfcns{3},'Pointer','arrow', ...
		 'Tag',ud.oldtag,'UserData',ud.oldud)

otherwise
   error('stats:gline:BadCallBack','Invalid call-back.');
end
