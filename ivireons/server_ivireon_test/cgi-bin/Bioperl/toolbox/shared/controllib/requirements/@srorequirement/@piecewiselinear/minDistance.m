function minDist = minDistance(this,TestPoints,Traj)
% MINDISTANCE  Computes minimum distance from TestPoints to requirement.
%
% Inputs:  
%         this        - srorequirement.piecewiselinear object
%         TestPoints  - nx2 double matrix of points to find minimum 
%                       distance for
%         Traj        - optional flag, if true treat TestPoints as a
%                       piecewise linear trajectory, default is false
%
% Outputs: 
%         minDist     - mxn vector of doubles with minimum distance of
%                       testpoint to each edge in the requirement, negative 
%                       values imply that requirement is satisfied

% Author(s): A. Stothert 25-Feb-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:57 $

%Process inputs
if nargin < 3, Traj = false; end

%Extract raw edge data
X = this.Data.getData('xdata');
Y = this.Data.getData('ydata');

%Compute Axes extent
AxExtent = [...
   max([X(:);TestPoints(:,1)])-min([X(:); TestPoints(:,1)]), ...
   max([Y(:);TestPoints(:,2)])-min([Y(:); TestPoints(:,2)])];

%Upper or lower bound?
if this.isLowerBound,
   Width = -1;
else
   Width = 1;
end

%Create parametric lines for all segments
Slope = [diff(X,[],2), diff(Y,[],2)];
%Add edges for end points
[X,Y,Slope] = localAddEndEdges(X,Y,Slope,Width,AxExtent,this.Data.getData('OpenEnd'));
mSlope = sum(Slope.^2,2); %Slope magnitude

if Traj
   %Find any points where trajectory intersects edges and add as testpoint
   TestPoints = localAddIntersects(X,Y,Slope,TestPoints);
end

%Find point 'r' along all lines that is nearest to testpoint. 
%Note 0 <= r <= 1 for point to remain on segment.
nEdge = size(X,1);
nPoints = size(TestPoints,1);
minDist = nan(nEdge,nPoints);
for iPoint = 1:nPoints
   Xp = TestPoints(iPoint,1)-X(:,1);    %Shift origin to startpoint of edge
   Yp = TestPoints(iPoint,2)-Y(:,1);    %Shift origin to startpoint of edge
   r = (Xp.*Slope(:,1)+Yp.*Slope(:,2))./mSlope;  %Closest point on edge to test point
   r = max(min(r,1),0);   %limit to line extents
   Xl = r.*Slope(:,1);    %Closest point on edge
   Yl = r.*Slope(:,2);    %Closest point on edge
   
   %Compute distances
   Dist = (Xp-Xl).^2+(Yp-Yl).^2;   %Distance of test point to each edge
   
   %Check whether points are feasible, use cross product of test point with 
   %end point of closest edge. 
   iMinDist = abs(Dist-min(Dist))<=sqrt(eps); %Find closest edge
   if sum(iMinDist)>1
      %Vertex is closest or right in middle of two edges, 
      %perturb slightly and re-find closest edge
      peturb = 0.001*sqrt(sum(AxExtent.^2))./sqrt(mSlope);   %peturb by a fixed amount
      rMove = r(iMinDist)+(-1).^ceil(r(iMinDist)).*peturb(iMinDist);
      Xl(iMinDist) = rMove.*Slope(iMinDist,1);
      Yl(iMinDist) = rMove.*Slope(iMinDist,2);
      rDist = (Xp-Xl).^2+(Yp-Yl).^2;
      iMinDist = abs(rDist-min(rDist))<=sqrt(eps);
      if sum(iMinDist)>1
         %Between two edges, select one
         iMinDist(iMinDist) = [true, false(sum(iMinDist)-1,1)];
      end
   end
   %Compute cross product, can use Slope as endpoint, as origin is startpoint 
   %of edge.
   Infeasible = 1*((Width*(Slope(iMinDist,1).*Yp(iMinDist)-...
      Slope(iMinDist,2).*Xp(iMinDist)))>=0);
   Infeasible(Infeasible == 0) = -1;

   %Set signed minimum distance for test point
   minDist(:,iPoint) = sqrt(Dist).*Infeasible;
end

%--------------------------------------------------------------------------
function [X,Y,Slope] = localAddEndEdges(X,Y,Slope,Width,AxExtent,OpenEnd)
%Local function to add end edges to edge collection. 

%Add new end points depending on end point open (parallel) or not open
%(perpendicular)
R = 2*sqrt(sum(AxExtent.^2));    %Make sure last edge is long enough
if OpenEnd(1)
   %Parallel
   XStart = [X(1)-R*Slope(1,1), X(1)];
   YStart = [Y(1)-R*Slope(1,2), Y(1)];
else
   %Perpendicular
   XStart = [X(1)-R*Width*Slope(1,2), X(1)];
   YStart = [Y(1)+R*Width*Slope(1,1), Y(1)];
end
if OpenEnd(2)
   %Parallel
   XEnd = [X(end), X(end)+R*Slope(end,1)];
   YEnd = [Y(end), Y(end)+R*Slope(end,2)];
else
   %Perpendicular
   XEnd = [X(end), X(end)-R*Width*Slope(end,2)];
   YEnd = [Y(end), Y(end)+R*Width*Slope(end,1)];
end
X = [XStart; X; XEnd];
Y = [YStart; Y; YEnd];

%Compute start and end edge slopes
StartEndSlope = [
   diff(XStart), diff(YStart); ...
   diff(XEnd), diff(YEnd)];

%Check to see if start and end edges intersect
A = [...
   -StartEndSlope(1,1), StartEndSlope(2,1); ...
   -StartEndSlope(1,2), StartEndSlope(2,2)];
if cond(A) < 1/sqrt(eps)
   %Rays intersect
   T = A\[ X(1)-X(end-1); Y(1)-Y(end-1)];
   %Make sure they intersect along positive dimension of rays
   if all(T>0), 
      %Rays intersect, adjust first and last point to meet at intersection
      X(end) = X(end-1) + T(2) * StartEndSlope(2,1);
      Y(end) = Y(end-1) + T(2) * StartEndSlope(2,2);
      X(1) = X(end);
      Y(1) = Y(end);
   end
end

%Adjust slope vectors to include new points
Slope = [diff(X,[],2), diff(Y,[],2)];

%--------------------------------------------------------------------------
function tOut = localAddIntersects(eX,eY,eSlope,tIn)

%Extract trajectory data
tX     = tIn(:,1);
tY     = tIn(:,2);
tSlope = [diff(tX), diff(tY)];

%Find any intersections of edges and trajectory and store intersection
%point
tAdd = zeros(0,2);
for ct_edge = 1:size(eX,1)
   %Prefilter to find possible crossings
   if abs(eSlope(ct_edge,1)) >= abs(eSlope(ct_edge,2))
      %Edge closer to horizontal
      c = eY(ct_edge,1)-eSlope(ct_edge,2)/eSlope(ct_edge,1)*eX(ct_edge,1);
      g = tY*eSlope(ct_edge,1) - tX*eSlope(ct_edge,2) - c*eSlope(ct_edge,1);
   else
      %Edge closer to vertical
      c = eX(ct_edge,1)-eSlope(ct_edge,1)/eSlope(ct_edge,2)*eY(ct_edge,1);
      g = tX*eSlope(ct_edge,2) - tY*eSlope(ct_edge,1) - c*eSlope(ct_edge,2);
   end
   %Look for sign changes
   idx = diff(sign(g)) ~= 0;
   if any(idx)
      %Have potential crossings, retrieve data of potential crossing
      %segments
      Slope = tSlope(idx,:);
      idx = find(idx);
      idx = [idx, idx+1];
      Ytc = tY(idx(:));
      Xtc = tX(idx(:));
      %Form segments
      Ytc = [Ytc(1:end-1), Ytc(2:end)];   
      Xtc = [Xtc(1:end-1), Xtc(2:end)];
      %Remove trajectory segments with both slopes = 0
      idx = abs(Slope(:,1)) > sqrt(eps) | ...
         abs(Slope(:,2)) > sqrt(eps);
      Ytc = Ytc(idx,:);
      Xtc = Xtc(idx,:);
      Slope = Slope(idx,:);
      
      %For each possible crossover, check for intersection
      for ct = 1:size(Xtc,1)
         T = localRayIntersect(...
            [eX(ct_edge,:); Xtc(ct,:)], ...
            [eY(ct_edge,:); Ytc(ct,:)], ...
            [eSlope(ct_edge,:); Slope(ct,:)]);
         if all(~isnan(T))
            %Have a valid intersection
            tAdd = [tAdd; ...
               [eX(ct_edge,1)+T(1)*eSlope(ct_edge,1), ...
               eY(ct_edge,1)+T(1)*eSlope(ct_edge,2)]];
         end
      end
   end
end

%Add any intersection points to testpoint list
tOut = [tIn; tAdd];

%--------------------------------------------------------------------------
function T = localRayIntersect(X,Y,Slope)

%Compute intersection of two rays
A = [-Slope(1,1), Slope(2,1); -Slope(1,2) Slope(2,2)];
if cond(A) < 1/sqrt(eps)
   %Lines intersect
   T = A\[X(1,1)-X(2,1); Y(1,1)-Y(2,1)];
   if any( T <0 | T > 1)
      %Intersection beyond end points of ray
      T = nan*T;
   end
else
   %Rays are parallel
   T = nan(2,1);
end
