function [vertXout,vertYout,XEdge,YEdge] = getConstrPoly(Constr,numP)
% Compute bounding polygons for a step response constraint. Note this
% method returns two polygons, one for the upper bound and one for the
% lower bound.
%
% Note coordinate data is returned in DisplayUnits units and not 
% stored units.

%   Author: A. Stothert 
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:33:55 $

outputEdges = nargout == 4;

XRaw    = Constr.Data.getData('xData');      %Unprocessed xVertices
YRaw    = Constr.Data.getData('yData');      %Unprocessed yVertices
OpenEnd = Constr.getData('OpenEnd');      %OpenEnd settings

%Check that we have a valid constraint
if ~all(size(XRaw) == size(YRaw))
   vertXout = cell(2,0); vertYout = cell(2,0);
   return
else
   nConstr = size(XRaw,1);                                 %Number of constraint edges
   %Make sure we've a valid selected edge
   SE = Constr.Data.getData('SelectedEdge');
   if any(SE > nConstr)
      SE = SE(SE <= nConstr);
      Constr.Data.setData('SelectedEdge',SE);
   end
end

%Check on the number of points to render along an edge
if nargin < 2, numP = 2; end

%Find the axes limits and extent
hGroup      = Constr.Elements;
PlotAxes    = hGroup.Parent;
AxLims      = zeros(1,4);
AxLims(1:2) = get(PlotAxes,'Xlim');
AxLims(3:4) = get(PlotAxes,'Ylim');
AxExtent    = zeros(1,2);

%Create parametric line(s) for each edge to avoid problems with infinite
%slopes
d       = zeros(nConstr,2);         %Direction vector for each edge
d(:,1)  = diff(XRaw,[],2);
d(:,2)  = diff(YRaw,[],2);
posStep = YRaw(1,1) >= YRaw(3,1);
isLower = [~posStep, posStep];

%Split data into upper and lower portions, loop over each portion
idx      = {1:2,3:5};
nConstr  = [2;3];
vertXout = cell(2,1);
vertYout = cell(2,1);
if outputEdges
   XEdge    = cell(2,1);
   YEdge    = cell(2,1);
end
for ct = 1:2
   r = ones(nConstr(ct),1)*(0:1/(numP-1):1);
   XData = XRaw(idx{ct},1)*ones(1,numP)+r.*(d(idx{ct},1)*ones(1,numP));
   YData = YRaw(idx{ct},1)*ones(1,numP)+r.*(d(idx{ct},2)*ones(1,numP));
   nData = numel(XData);   %Number of points on "main" edge of constraint

   %Send the edge vertices for output if requested
   vertXEdge = unitconv(XData',Constr.Data.getData('xUnits'),Constr.xDisplayUnits);
   vertYEdge = unitconv(YData',Constr.Data.getData('yUnits'),Constr.yDisplayUnits);
   vertX = reshape(vertXEdge,nData,1);
   vertY = reshape(vertYEdge,nData,1);
   
   %Compute axes extent based on current settings and vertices
   AxExtent(1) = max(AxLims(2)-AxLims(1),max(abs(vertX(:))));
   AxExtent(2) = max(AxLims(4)-AxLims(3),max(abs(vertY(:))));

   %Determine width to see if points are to be added
   %above or below bound to close polygon
   if isLower(ct)
      Width = -2;
   else
      Width = 2;
   end

   %Ready to construct polygon
   %Check if we're on a semilog x axis and compute appropriate slopes
   Slope = [...
      diff(XRaw(1,:)), diff(YRaw(1,:)); ...
      diff(XRaw(end,:)), diff(YRaw(end,:))];

   %Project first edge
   if OpenEnd(1)
      %Edge should be parallel to first edge
      R = (vertX(1)-AxLims(1))/Slope(1,1);
      vertX = [AxLims(1); vertX(1) - R*Slope(1,1); vertX];
      vertY = [vertY(1)+Width*AxExtent(2); vertY(1) - R*Slope(1,2); vertY];
   else
      %Edge should be parallel to y-axis
      vertX = [vertX(1); vertX;];
      vertY = [vertY(1) + Width*AxExtent(2); vertY];
   end
   %Project last edge
   if OpenEnd(2)
      %Edge should be parallel to last edge
      R = (AxLims(2)-vertX(end))/Slope(2,1);
      vertX = [vertX; vertX(end) + R*Slope(2,1); AxLims(2)];
      vertY = [vertY; vertY(end) + R*Slope(2,2); vertY(end)+Width*AxExtent(2)];
   else
      %Edge should be parallel to y-axis
      vertX = [vertX; vertX(end)];
      vertY = [vertY; vertY(end)+Width*AxExtent(2)];
   end
   
   %Remove duplicate and 'near' points at ends of line segments
   idxFar = ~(diff(vertX,[],1).^2+diff(vertY,[],1).^2 < sqrt(eps));
   if ~any(idxFar)
      vertX = vertX(idxFar); vertY = vertY(idxFar);
   end
   
   if outputEdges
      XEdge{ct} = vertXEdge;
      YEdge{ct} = vertYEdge;
   end
   vertXout{ct} = vertX;
   vertYout{ct} = vertY;
end