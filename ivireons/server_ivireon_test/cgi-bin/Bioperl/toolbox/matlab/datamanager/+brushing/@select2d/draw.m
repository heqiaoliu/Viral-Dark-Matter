function region = draw(this,varargin)
% This internal helper function may change in a future release.

% DRAW returns the geometry of the cross section:
%
% DRAW returns the geometry of the cross section in axes data coordinates
% and draws the brushing corresponding brushing rectangle in the scribe
% layer after clipping it to the axes bounds. Current figure mouse position
% is determined from the eventData or the figure 'CurrentPoint' property,
% current axes data mouse position is determined from the axes
% 'CurrentPoint' property.

%  Copyright 2008-2009 The MathWorks, Inc.

if feature('HGUsingMATLABClasses')
    region = drawHGUsingMatlabClasses(this,varargin{:});
    return
end

% Get vertices
fig = this.Figure;
ax = this.Axes;
scribeDragStart = this.ScribeStartPoint;
axesDragEnd = get(ax,'CurrentPoint');
axesDragStart = this.AxesStartPoint;
figUnits = get(fig,'Units');
if nargin>=2 % WindowButtonMotion.CurrentPoint events are always in pixels
    scribeDragEnd = get(varargin{1},'CurrentPoint');
    scribeDragEnd = hgconvertunits(fig,[scribeDragEnd 0 0],'pixels','Normalized',fig); 
else
    scribeDragEnd = get(fig,'CurrentPoint');
    scribeDragEnd = hgconvertunits(fig,[scribeDragEnd 0 0],figUnits,'Normalized',fig); 
end


% Convert scribe vertices to Normalized units
scribeLayer = this.ScribeLayer;
scribeDragStart = hgconvertunits(fig,[scribeDragStart 0 0],figUnits,'Normalized',fig);
scribeDragStart = scribeDragStart(1:2);
scribeDragEnd = scribeDragEnd(1:2);
axesPos = hgconvertunits(fig,getpixelposition(ax,true),'pixels','Normalized',fig);

% Clip to the axes bounds.
scribeDragStart = [max(scribeDragStart(1),axesPos(1)) max(scribeDragStart(2),axesPos(2))];
scribeDragStart = [min(scribeDragStart(1),axesPos(1)+axesPos(3)) min(scribeDragStart(2),axesPos(2)+axesPos(4))];
scribeDragEnd = [max(scribeDragEnd(1),axesPos(1)) max(scribeDragEnd(2),axesPos(2))];
scribeDragEnd = [min(scribeDragEnd(1),axesPos(1)+axesPos(3)) min(scribeDragEnd(2),axesPos(2)+axesPos(4))];
region = localGetRectangleGeom(axesDragStart,axesDragEnd,ax);

% Create/draw a selection rectangle
xpos = min(scribeDragEnd(1),scribeDragStart(1));
wd = max(abs(scribeDragEnd(1)-scribeDragStart(1)),axesPos(3)/100);
ypos = min(scribeDragEnd(2),scribeDragStart(2));
ht = max(abs(scribeDragEnd(2)-scribeDragStart(2)),axesPos(4)/100);
posVec = [xpos ypos wd ht];
r = this.Graphics;
t = this.Text;
if isempty(r)
    this.Graphics = rectangle('Parent',scribeLayer,...
            'Position',posVec);
    this.Text = text(scribeDragStart(1),scribeDragStart(2),'','FontSize',8,'Color',[0 0 1],...
        'Tag','Brushing','Parent',scribeLayer);   
else
    set(r,'Position',posVec);
    ex = get(t,'extent');
    set(t,'Position',[xpos ypos-ex(4)/2],...
        'String',sprintf('X: %0.3g to %0.3g Y: %0.3g to %0.3g',region(1,1),...
        region(1,1)+region(2,1),region(1,2),region(1,2)+region(2,2)));
end   
region = [region(1,:),region(2,:)];

function region = localGetRectangleGeom(point1,point2,ax)
     
% Find the bottom-right and top-left rectangle vertices
point1 = point1(1,1:2);
point2 = point2(1,1:2);
p1 = min(point1,point2);
xlim = get(ax,'xlim');
ylim = get(ax,'ylim');
if strcmp(get(ax,'xscale'),'log')
    xdiff = xlim(1)*log(10)*log10(xlim(2)/xlim(1))/200;
else
    xdiff = diff(xlim)/200;
end
if strcmp(get(ax,'yscale'),'log')
    ydiff = ylim(1)*log(10)*log10(ylim(2)/ylim(1))/200;
else
    ydiff = diff(ylim)/200;
end
offset = max(abs(point1-point2),[xdiff ydiff]);
region = [p1;offset];

