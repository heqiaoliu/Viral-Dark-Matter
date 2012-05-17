function [vertX,vertY,vertXEdge,vertYEdge] = getConstrPoly(Constr,numP)
% Compute bounding polygon for constraint. Note coordinate data is returned
% in DisplayUnits units and not stored units.

%   Author: A. Stothert 
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:32:36 $

XRaw    = Constr.getData('xCoords');      %Unprocessed xVertices
YRaw    = Constr.getData('yCoords');      %Unprocessed yVertices
OpenEnd = Constr.getData('OpenEnd');   %OpenEnd settings

%Check that we have a valid constraint
if ~all(size(XRaw) == size(YRaw))
   vertX = []; vertY = [];
   return
else
   nConstr = size(XRaw,1);                                 %Number of constraint edges
   isLower = strcmp(Constr.getData('Type'),'lower');       %Is a lower constraint type
   %Make sure we've a valid selected edge
   SE = Constr.getData('SelectedEdge');
   if any(SE > nConstr)
      SE = SE(SE <= nConstr);
      Constr.setData('SelectedEdge',SE);
   end
end

%Check on the number of points to render along an edge
if nargin < 2, numP = 2; end

HostAx = handle(Constr.Elements.Parent);
isLogX = strncmpi(HostAx.Xscale,'log',3);
isLogY = strncmpi(HostAx.Yscale,'log',3);
if isLogX
   %Logarithmic X axis
   XRaw = log10(XRaw);
end
%Create parametric line(s) for each edge to avoid problems with infinite
%slopes
d = zeros(nConstr,2);         %Direction vector for each edge
d(:,1) = diff(XRaw,[],2);
d(:,2) = diff(YRaw,[],2);       
r = ones(nConstr,1)*(0:1/(numP-1):1);
XData = XRaw(:,1)*ones(1,numP)+r.*(d(:,1)*ones(1,numP));
YData = YRaw(:,1)*ones(1,numP)+r.*(d(:,2)*ones(1,numP));
nData = numel(XData);   %Number of points on "main" edge of constraint
if isLogX
   %Logarithmic xAxis
   XData  = 10.^XData;
   XRaw   = 10.^XRaw;
end

if nargout == 4
   %Send the edge vertices for output if requested
   vertXEdge = unitconv(XData',Constr.getData('xUnits'),Constr.xDisplayUnits);
   vertYEdge = unitconv(YData',Constr.getData('yUnits'),Constr.yDisplayUnits);
   vertX = reshape(vertXEdge,nData,1);
   vertY = reshape(vertYEdge,nData,1);
else
   %Convert vertices to units of axes
   vertX = unitconv(...
      reshape(XData',nData,1),...
      Constr.getData('xUnits'),...
      Constr.xDisplayUnits);
   vertY = unitconv(...
      reshape(YData',nData,1),...
      Constr.getData('yUnits'),...
      Constr.yDisplayUnits);
end

%Find the axes limits and extent
PlotAxes    = Constr.Elements.Parent;
AxLims      = zeros(1,4);
AxLims(1:2) = get(PlotAxes,'Xlim');
AxLims(3:4) = get(PlotAxes,'Ylim');
AxExtent    = zeros(1,2);
AxExtent(1) = max(AxLims(2)-AxLims(1),max(abs(vertX(:))));
AxExtent(2) = max(AxLims(4)-AxLims(3),max(abs(vertY(:))));

%Determine width to see if points are to be added
%above or below bound to close polygon
if isLower
   Width = -2;
else
   Width = 2;
end

%Ready to construct polygon
switch Constr.Orientation
   case 'both'
      %Depending on OpenEnd setting, edges should be orthogonal/ parallel 
      %to end segments. 
      
      %Add two extra vertices to close polygon
      vertX = [vertX; zeros(2,1)];
      vertY = [vertY; zeros(2,1)];

      %Work out the slope of the end segments
      Slope = zeros(2,2);
      Slope(1,:) = [...
               diff(XRaw(1,:)),...
               diff(YRaw(1,:))];
      Slope(2,:) = [...
               diff(XRaw(nConstr,:)),...
               diff(YRaw(nConstr,:))];      
      %Normalize the slope
      Slope = Slope./(sqrt(sum(Slope.^2,2))*[1 1]);
      
      %Now add point to end edges.
      R = sqrt(sum(AxExtent.^2));
      if OpenEnd(2)
         %Edge parallel to last real edge
         vertXpr = vertX(nData) + R*Slope(2,1);
         vertYpr = vertY(nData) + R*Slope(2,2);
      else
         %Edge perpendicular to last real edge
         vertXpr = vertX(nData) - ( Width*R*Slope(2,2) );
         vertYpr = vertY(nData) + ( Width*R*Slope(2,1) );
      end
      if OpenEnd(1)
         %Edge parallel to first real edge
         vertXpl = vertX(1) - R*Slope(1,1);
         vertYpl = vertY(1) - R*Slope(1,2);
      else
         %Edge perpendicular to first real edge
         vertXpl = vertX(1) - ( Width*R*Slope(1,2) );
         vertYpl = vertY(1) + ( Width*R*Slope(1,1) );
      end
    
      %Check to see if the rays along the projected point intersect.
      nSlope = zeros(2,2);
      nSlope(1,:) = [vertXpl-vertX(1), vertXpr-vertX(nData)];
      nSlope(2,:) = [vertYpl-vertY(1), vertYpr-vertY(nData)]; 
      A = [nSlope(:,1), -nSlope(:,2)];
      Inter = false;
      if cond(A) < 1/sqrt(eps)
         %Rays intersect
         T = A\[ -vertX(1)+vertX(nData); -vertY(1)+vertY(nData)];
         %Make sure they intersect along positive dimension of rays
         if all(T>0), Inter = true; end
      end
      if Inter
         %Edges intersect and close shape
         vertX(nData+1) = vertX(nData)+T(2)*nSlope(1,2);
         vertY(nData+1) = vertY(nData)+T(2)*nSlope(2,2);
         vertX(nData+2) = vertX(1);
         vertY(nData+2) = vertY(1);
         %Check if feasible region is inside or outside patch
         a = localPolyArea(vertX,vertY)<0;
         inside = a && isLower || ~a && ~isLower;
         if ~inside
            %Need to add patch outside of constraint
            Xleft  = AxLims(1)*( 1-0.1*sign(AxLims(1))) - 0.01*AxExtent(1);
            Xleft  = min(Xleft,min(vertX(:)));
            Xright = AxLims(2)*( 1+0.1*sign(AxLims(2))) + 0.01*AxExtent(1);
            Xright = max(Xright,max(vertX(:)));
            Ybot   = AxLims(3)*( 1-0.1*sign(AxLims(3))) - 0.01*AxExtent(2);
            Ybot   = min(Ybot,min(vertY(:)));
            Ytop   = AxLims(4)*( 1+0.1*sign(AxLims(4))) + 0.01*AxExtent(2);
            Ytop   = max(Ytop,max(vertY(:)));
            Corners = [Xleft Ybot; Xleft Ytop; Xright Ytop; Xright Ybot; Xleft Ybot];
            vertX = [vertX(1:nData+1); Corners(:,1); vertX((nData+1):(nData+2))];
            vertY = [vertY(1:nData+1); Corners(:,2); vertY((nData+1):(nData+2))];
         end
      else
         %Edges are parallel or don't close
         vertX = [vertXpl; vertX(1:nData); vertXpr];
         vertY = [vertYpl; vertY(1:nData); vertYpr];
         %Find a point perpendicular to line joining
         %ends of segment and draw arc to connect end points.
         Slope = zeros(1,2);
         Slope(1:2) = [vertX(nData+2)-vertX(1), vertY(nData+2)-vertY(1)];
         Slope = Slope./(sqrt(sum(Slope.^2,2))*[1 1]);
         midPX = 0.5*(vertX(1)+vertX(nData+2));
         midPY = 0.5*(vertY(1)+vertY(nData+2));
         if isLower
            Slope = Slope*[0 -1; 1 0];  %-pi/2 rotation
         else
            Slope = Slope*[0 1; -1 -0]; %pi/2 rotation 
         end
         R = 4*sqrt(sum(AxExtent.^2));
         midPX = R*Slope(1)+midPX;
         midPY = R*Slope(2)+midPY;
         %Now draw circle using computed point as centre to
         %enclose correct axes corners.
         angL = atan2(vertY(1)-midPY,vertX(1)-midPX);
         if angL < 0; angL = angL+2*pi; end
         angR = atan2(vertY(end)-midPY,vertX(end)-midPX);
         if angR < 0; angR = angR+2*pi; end
         R = sqrt((midPX-vertX(1))^2+(midPY-vertY(1))^2);
         if isLower&&angL>=angR, angL = angL-2*pi; end %Forces Lend smaller than Rend
         if ~isLower&&angL<=angR, angL = angL+2*pi; end
         theta = angR:(angL-angR)/20:angL;
         Corners = zeros(numel(theta),2);
         Corners(:,1) = R*cos(theta)'+midPX;
         Corners(:,2) = R*sin(theta)'+midPY;
         vertX = [vertX; Corners(:,1)];
         vertY = [vertY; Corners(:,2)];
      end
   case 'horizontal'
       %Check if we're on a semilog x axis and compute appropriate slopes
      if isLogX
         Slope = [...
            diff(log10(XRaw(1,:))), diff(YRaw(1,:)); ...
            diff(log10(XRaw(end,:))), diff(YRaw(end,:))];
      else
         Slope = [...
            diff(XRaw(1,:)), diff(YRaw(1,:)); ...
            diff(XRaw(end,:)), diff(YRaw(end,:))];
      end
      %Project first edge
      if OpenEnd(1)
         %Edge should be parallel to first edge
         if isLogX
            R = (log10(vertX(1))-log10(eps))/Slope(1,1);
            vertX = [...
               eps; ...
               10^(log10(vertX(1))-R*Slope(1,1)); ...
               vertX];
            vertY = [vertY(1)+Width*AxExtent(2); vertY(1)-R*Slope(1,2); vertY];
         else
            R = (vertX(1)-AxLims(1))/Slope(1,1);
            vertX = [AxLims(1); vertX(1) - R*Slope(1,1); vertX];
            vertY = [vertY(1)+Width*AxExtent(2); vertY(1) - R*Slope(1,2); vertY];
         end
      else
         %Edge should be parallel to y-axis
         vertX = [vertX(1); vertX;];
         vertY = [vertY(1) + Width*AxExtent(2); vertY];
      end
      %Project last edge
      if OpenEnd(2)
         %Edge should be parallel to last edge
         if isLogX
           R = (log10(AxLims(2))-log10(vertX(end)))/Slope(2,1);
           vertX = [...
              vertX; ...
              10^(log10(vertX(end)) + R*Slope(2,1)); ...
              10^(log10(vertX(end)) + R*Slope(2,1));];
           vertY = [vertY; vertY(end) + R*Slope(2,2); vertY(end)+Width*AxExtent(2)];
         else
            R = (AxLims(2)-vertX(end))/Slope(2,1);
            vertX = [vertX; vertX(end) + R*Slope(2,1); AxLims(2)];
            vertY = [vertY; vertY(end) + R*Slope(2,2); vertY(end)+Width*AxExtent(2)];
         end
      else
         %Edge should be parallel to y-axis
         vertX = [vertX; vertX(end)];
         vertY = [vertY; vertY(end)+Width*AxExtent(2)];
      end
         
   case 'vertical'
      %Check if we're on a semilog y axis and compute appropriate slopes
      if isLogY
         Slope = [...
            diff(XRaw(1,:)), diff(log10(YRaw(1,:))); ...
            diff(XRaw(end,:)), diff(log10(YRaw(end,:)))];
      else
         Slope = [...
            diff(XRaw(1,:)), diff(YRaw(1,:)); ...
            diff(XRaw(end,:)), diff(YRaw(end,:))];
      end
      %Project first edge
      if OpenEnd(1)
         %Edge should be parallel to first edge
         if isLogX
            R = (log10(vertY(1))-log10(AxLims(3)))/Slope(1,2);
            vertY = [...
               eps; ...
               10^(log10(vertY(1))-R*Slope(1,2)); ...
               vertY];
            vertX = [vertX(1)+Width*AxExtent(1); vertX(1) - R*Slope(1,1); vertX];
         else
            R = (vertY(1)-AxLims(3))/Slope(1,2);
            vertY = [AxLims(3); vertY(1)-R*Slope(1,2); vertY];
            vertX = [vertX(1)+Width*AxExtent(1); vertX(1)-R*Slope(1,1); vertX];
         end
      else
         %Edge should be parallel to x-axis
         vertX = [vertX(1) + Width*AxExtent(1); vertX;];
         vertY = [vertY(1); vertY];
      end
      %Project last edge
      if OpenEnd(2)
         %Edge should be parallel to last edge
         if isLogY
           R = (log10(AxLims(4))-log10(vertY(end)))/Slope(2,2); 
           vertY = [...
              vertY; ...
              10^(log10(vertY(end)) + R*Slope(2,2)); ...
              10^(log10(vertY(end)) + R*Slope(2,2));];
           vertX = [vertX; vertX(end) + R*Slope(2,1); vertX(end)+Width*AxExtent(1)];
         else
            R = (AxLims(4)-vertY(end))/Slope(2,2);
            vertY = [vertY; vertY(end) + R*Slope(2,2); AxLims(4)];
            vertX = [vertX; vertX(end) + R*Slope(2,1); vertX(end)+Width*AxExtent(1)];
         end
      else
         %Edge should be parallel to y-axis
         vertX = [vertX; vertX(end)+Width*AxExtent(1)];
         vertY = [vertY; vertY(end)];
      end
end

%Remove duplicate and 'near' points at ends of line segments
idx = ~(diff(vertX,[],1).^2+diff(vertY,[],1).^2 < sqrt(eps));
if ~any(idx)
   vertX = vertX(idx); vertY = vertY(idx);
end

%--------------------------------------------------------------------------
function Value = localPolyArea(X,Y)

% Compute signed area of polygon given it's vertices
Value = 0.5*sum(X(1:end-1).*Y(2:end)-X(2:end).*Y(1:end-1));
