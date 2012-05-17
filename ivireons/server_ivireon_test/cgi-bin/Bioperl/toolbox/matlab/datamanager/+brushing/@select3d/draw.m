function crossX = draw(this,varargin)
% This internal helper function may change in a future release.

% DRAW draws a region of interest (ROI) based on a brushing drga gesture.
%
% DRAW returns the geometry of the cross section as a 2x2 matrix where 
% each row represents the pair of coordinates in figure normailzied units.
% Note that unlike 2d data brushing, 3d data brushing uses the figure
% coorinates ratehr that the axes coordinates to take advantage of the hg
% projection functionality. Note that the ROI will be clipped to the axes
% bounds.

%  Copyright 2008-2009 The MathWorks, Inc.
    
if feature('HGUsingMATLABClasses')
    crossX = drawHGUsingMatlabClasses(this,varargin{:});
    return
end

% Get vertices
fig = this.Figure;
ax = this.Axes;
scribeDragStart = this.ScribeStartPoint;
figUnits = get(fig,'Units');
if nargin>=2 % WindowButtonMotion.CurrentPoint events are always in pixels
    scribeDragEnd = get(varargin{1},'CurrentPoint');
    scribeDragEnd = hgconvertunits(fig,[scribeDragEnd 0 0],'pixels','Normalized',fig);
else
    scribeDragEnd = get(fig,'CurrentPoint');
    scribeDragEnd = hgconvertunits(fig,[scribeDragEnd 0 0],figUnits,'Normalized',fig);
end

% Convert scribe vertices to Normalized figure units
scribeLayer = this.ScribeLayer;
scribeDragStart = hgconvertunits(fig,[scribeDragStart 0 0],figUnits,'Normalized',fig);
axespos = hgconvertunits(fig,getpixelposition(ax,true),'pixels','Normalized',fig);

% Clip the end drag position. Allow the brushing rectangle in 3d to extend
% 5 percent beyond the axes limits in x,y,z directions to ensure that points on the
% edge are brushable even after rounding.
scribeDragEnd(1) = min(max(scribeDragEnd(1),axespos(1)-axespos(3)*0.05),axespos(1)+axespos(3)*1.05);
scribeDragEnd(2) = min(max(scribeDragEnd(2),axespos(2)-.05*axespos(4)),axespos(2)+axespos(4)*1.05);

% Draw the ROI.
xpos = [scribeDragStart(1) scribeDragEnd(1) scribeDragEnd(1) scribeDragStart(1)];
ypos = [scribeDragStart(2) scribeDragStart(2)  scribeDragEnd(2) scribeDragEnd(2)];
r = this.Graphics;
if isempty(r) % Create it
    this.Graphics = patch('FaceColor',[.9 .9 1],'Parent',scribeLayer,...
        'FaceAlpha',0.2,'xdata',xpos,'ydata',ypos);
else % Draw it
    set(r,'xdata',xpos,'ydata',ypos,'Visible','on');
end

% Return the cross-section geometry.
crossX = [scribeDragStart(:)';scribeDragEnd(:)'];
