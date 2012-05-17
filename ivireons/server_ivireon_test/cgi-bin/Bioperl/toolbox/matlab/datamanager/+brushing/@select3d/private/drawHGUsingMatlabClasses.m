function figRegionCoords = drawHGUsingMatlabClasses(this,~)
% This internal helper function may change in a future release.

% DRAW returns the geometry of the cross section in figure coordinates
% and draws the brushing corresponding brushing rectangle in the overlay
% layer after clipping it to the axes bounds. 
%
% Note the following key difference between this method and the
% corresponding select2d::drawHGUsingMatlabClasses for 2d axes:
% For 2-d axes the select2d::drawHGUsingMatlabClasses
% method returns a representation of a 2d data space x-y rectangle in
% figure coordinates so that the ROI for non-linear data spaces is shaped 
% in accordance with the non-linear coordinates. For example, in a polar
% coordinate system the 2d ROI will appear as a segment representing a
% range of radii and theta values. To migrate this approach to 3d axes
% requires mapping a 3d ROI prism in data coordinates to a 2d polygon in
% camera coordinates. This will result in a non-rectangular ROI
% representing selection of a range of x,y,z values. Since this is a
% departure from compatibility, it requires further review and
% consideration.


%  Copyright 2009-2010 The MathWorks, Inc.

% Get ROI vertices in figure coords
fig = this.Figure;
ax = this.Axes;
figDragEnd = get(fig,'CurrentPoint');
figDragStart = this.ScribeStartPoint;

% Find the cubic hull of the axes vertices
xlim = get(ax,'xlim');
ylim = get(ax,'ylim');
zlim = get(ax,'zlim');
iter = matlab.graphics.axis.dataspace.XYZPointsIteratorObject;
iter.XData = [xlim(1) xlim(2) xlim(2) xlim(1) xlim(1) xlim(2) xlim(2) xlim(1)];
iter.YData = [ylim(1) ylim(1) ylim(1) ylim(1) ylim(2) ylim(2) ylim(2) ylim(2)];
iter.ZData = [zlim(1) zlim(1) zlim(2) zlim(2) zlim(1) zlim(1) zlim(2) zlim(2)];
camAxesVertices = TransformPoints(ax.DataSpaceHandle,[],iter);
figAxesVertices = brushing.select.transformCameraToFigCoord(ax,camAxesVertices);
minX = min(figAxesVertices(1,:));
maxX = max(figAxesVertices(1,:));
minY = min(figAxesVertices(2,:));
maxY = max(figAxesVertices(2,:));

% Clip ROI in figure space to axes vertices
figDragEnd(1) = max(min(figDragEnd(1),maxX),minX);
figDragEnd(2) = max(min(figDragEnd(2),maxY),minY);
figDragStart(1) = max(min(figDragStart(1),maxX),minX);
figDragStart(2) = max(min(figDragStart(2),maxY),minY);
figRegionCoords = [figDragStart(1) figDragStart(2);...
                   figDragEnd(1) figDragStart(2);...
                   figDragEnd(1) figDragEnd(2);...
                   figDragStart(1) figDragEnd(2);...
                   figDragStart(1) figDragStart(2)]';
% If the height or width of the ROI is less than 0.5% of the axes limits,
% then select nothing and hide the ROI tool.
if abs(figDragEnd(1)-figDragStart(1))<0.005*(maxX-minX) || ...
    abs(figDragEnd(2)-figDragStart(2))<0.005*(maxY-minY)
   if ~isempty(this.Graphics) && isvalid(this.Graphics) && strcmp(this.Graphics.Visible,'on')
       this.Graphics.Visible = 'off';
   end
   return
end 

% Get figure coordinates of brushing ROI for drawing ROI
% into the overlay camera in normalized figure units.
vertexData = zeros([3 size(figRegionCoords,2)]);
for k=1:size(figRegionCoords,2)
    tmp = hgconvertunits(fig,[figRegionCoords(:,k)' 0 0],'pixels','normalized',fig);
    vertexData(1:2,k) = tmp(1:2);
end
               
r = this.Graphics;
if isempty(r)
    ol = graph2dhelper('findScribeLayer',fig);
    this.Graphics = matlab.graphics.primitive.world.Line('parent',ol);
    set(this.Graphics,'ColorData',uint8([255;0;0;255]),...
      'ColorBinding','object',...
      'HandleVisibility','off',...
      'Hittest','off',...
      'LineWidth',0.5,'VertexData',single(vertexData),'StripData',uint32([1 size(vertexData,2)+1]));
else
    set(this.Graphics,'VertexData',single(vertexData),'StripData',uint32([1 size(vertexData,2)+1]),'Visible','on');
end




