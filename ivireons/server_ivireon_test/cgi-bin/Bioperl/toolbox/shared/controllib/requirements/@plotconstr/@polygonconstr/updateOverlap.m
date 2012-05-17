function updateOverlap(Constr,X,Y)
% Check axes to see if it contains any other constraints and whether
% this constraint overlaps them to prevent feasible solutions. 

%   Author: A. Stothert 
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:33:01 $

XRaw = Constr.getData('xCoords');
YRaw = Constr.getData('yCoords');
nConstr = size(Constr.getData('xCoords'),1);
   
%Check that we have a valid constraint to render
if ~all( size(XRaw) == size(YRaw) ) || ...
      size(Constr.getData('Linked'),1) ~= nConstr-1 
   return
else
   %Make sure we've a valid selected edge
   SE = Constr.getData('SelectedEdge');
   SE = SE(SE <= nConstr);
   Constr.setData('SelectedEdge',SE);
end

if strncmpi(Constr.Orientation,'both',3)
   %Does not make sense to check overlap.
   Constr.ConstraintOverlap = false;
   return
end

numP = 50;
if nargin < 2
   %Use current co-ords not proposed co-ords
   X = XRaw;
   Y = YRaw;
end

%Find other constraints on this plot
[vertX,vertY] = localFindOtherConstraints(Constr);

%Check if we need to convert to log-scale.
hAx = Constr.Elements.Parent;
if strncmpi(get(hAx,'Xscale'),'log',3)
   X = log10(X);
   for iVert = 1:numel(vertX)
      vertX{iVert} = log10(vertX{iVert});
   end
end

%Compute a number of points along the constraint boundary
[Xline, Yline] = localComputeLine(X,Y,numP);

%Check that the line does not lie inside any of the other polygons
inside = 0;
iConstr = 1;
while ~any(inside) && iConstr <= numel(vertX)
   if ~isempty(vertX{iConstr})&& ~isempty(vertY{iConstr})
      inside = inpolygon(Xline,Yline,vertX{iConstr},vertY{iConstr});
   end
   iConstr = iConstr+1;
end

%Set the element's overlap property
if any(inside)~=Constr.ConstraintOverlap
   Constr.ConstraintOverlap = ~Constr.ConstraintOverlap;
end

%--------------------------------------------------------------------------
function [xLine, yLine] = localComputeLine(X,Y,numP)

%Create parametric line to avoid infinite slope problems
Slope = atan2(diff(Y,[],2),diff(X,[],2));
R = sqrt(diff(X,[],2).^2+diff(Y,[],2).^2);
r = R*(0:1/(numP-1):1);
xLine = X(:,1)*ones(1,numP)+r.*(cos(Slope)*ones(1,numP));
yLine = Y(:,1)*ones(1,numP)+r.*(sin(Slope)*ones(1,numP));

xLine = reshape(shiftdim(xLine,1),numel(xLine),1);
yLine = reshape(shiftdim(yLine,1),numel(yLine),1);

%--------------------------------------------------------------------------
function [vertX,vertY] = localFindOtherConstraints(Constr)

%Search the parent axis of this constraint for any related
%constraints
HostAx = handle(Constr.Elements.Parent);
if strncmpi(Constr.getData('Type'),'lower',3)
   MatchType = 'upper';
else
   MatchType = 'lower';
end
idx = plotconstr.findConstrOnAxis(HostAx);
idx = find(idx,'-isa','plotconstr.polygonconstr','Type',MatchType);
idx = idx(idx~=Constr);

%Now retrieve bounding polygons for related constraints
vertX = cell(numel(idx),1);
vertY = cell(numel(idx),1);
for iConstr = 1:numel(idx)
   [X,Y] = idx(iConstr).getConstrPoly;
   if iscell(X)
      vertX{iConstr} = X{1};
      for ct=2:numel(X), vertX{end+1} = X{ct}; end
   else
      vertX{iConstr} = X;
   end
   if iscell(Y)
      vertY{iConstr} = Y{1};
      for ct=2:numel(Y), vertY{end+1} = Y{ct}; end
   else
      vertY{iConstr} = Y;
   end
end



