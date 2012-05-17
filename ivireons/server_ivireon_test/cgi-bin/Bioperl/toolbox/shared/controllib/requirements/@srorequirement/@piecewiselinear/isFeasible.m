function bFeasible = isFeasible(this,Req)
% ISFEASIBLE  Method to check feasibility against another requirement
%
% This method checks that requirements of the same orientation and with the same source 
% don't overlap when they have different upper/lower bound settings
 
% Author(s): A. Stothert 07-Aug-2006
% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:55 $

bFeasible = true;
if this == Req
   %Quick exit, same requirement
   return;
end
if ~strcmpi(this.Orientation,Req.Orientation)
   %Quick exit, don't have same orientation
   return;
end
if ~isequal(this.getSource('c'),Req.getSource('c'))
   %Quick exit, different sources
   return
end
if this.isLowerBound == Req.isLowerBound
   %Quick exit, same bound type
   return
end

%Retrieve x, y data
if this.isLowerBound
   lb = this;
   ub = Req;
else
   lb = Req;
   ub = this;
end
ubX = ub.getData('xData');
lbX = lb.getData('xData');
ubY = ub.getData('yData');
lbY = lb.getData('yData');

% All upper bound vertices should be above lower bound
nbnd = size(ubX,1);
ubvx = [ubX(:,1) ; ubX(nbnd,2)];
ubvy = [ubY(1,1) ; ...
   min(ubY(2:nbnd,1),ubY(1:nbnd-1,2)) ; ...
   ubY(nbnd,2)];
for ct=1:nbnd+1
   % Find lower bound below upper bound vertex #ct
   idx = find(lbX(:,1)<=ubvx(ct),1,'last');
   if isempty(idx)
      %No lower bound below vertex
      idx(1) = 1; %Can choose this as is case with no bound at start time
   end
   % Find lower bound value at x=UBVX(ct)
   if lbX(idx,1)==ubvx(ct)
      lby = lbY(idx,1);
      if idx>1
         lby = max(lby,lbY(idx-1,2));
      end
   else
      % interpolate
      lby = interp1(lbX(idx,:),lbY(idx,:),ubvx(ct));
   end
   % Compare
   if lby>ubvy(ct)
      bFeasible = false; return
   end
end

% All lower bound vertices should be below upper bound
nbnd = size(lbX,1);
lbvx = [lbX(:,1) ; lbX(nbnd,2)];
lbvy = [lbY(1,1) ; ...
   max(lbY(2:nbnd,1),lbY(1:nbnd-1,2)) ; ...
   lbY(nbnd,2)];
for ct=1:nbnd+1
   % Find upper bound above lower bound vertex #ct
   idx = find(ubX(:,1)<=lbvx(ct),1,'last');
   if isempty(idx)
      %No upper bound above vertex
      idx(1) = 1; %Can choose this as is case with no bound at start time
   end
   % Find lower bound value at x=UBVX(ct)
   if ubX(idx,1)==lbvx(ct)
      uby = ubY(idx,1);
      if idx>1
         uby = min(uby,ubY(idx-1,2));
      end
   else
      % interpolate
      uby = interp1(ubX(idx,:),ubY(idx,:),lbvx(ct));
   end
   % Compare
   if uby<lbvy(ct)
      bFeasible = false; return
   end
end

