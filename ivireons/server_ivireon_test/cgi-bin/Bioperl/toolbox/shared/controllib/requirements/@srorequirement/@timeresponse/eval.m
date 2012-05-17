function c = eval(this,Response)
% Evaluates time response requirement for given signal. 
%
% Inputs:
%          this      - a srorequirement.signaltracking object.
%          Response  - An n-by-m matrix with the signal to evaluate, the first 
%                      column is the time vector, subsequent columns the response.
% Outputs: 
%          c - an n-by-m matrix of doubles giving the maximum signed distance 
%          of each signal to each edge of the requirement. A negative value 
%          indicates a feasible point.
 
% Author(s): A. Stothert 25-Feb-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:37:18 $

if isempty(Response)
   c = [];
   return
end

if size(Response,1)==1 && any(isnan(Response))
   % Trying to evaluate invalid response
   c = 1e8 + 1i;
   return
end

%Retrieve basic constraint data
XRaw    = this.Data.getData('xdata');
YRaw    = this.Data.getData('ydata');
OpenEnd = this.Data.getData('OpenEnd');
tRange  = [...
   min([XRaw(:); Response(:,1)]), ...
   max([XRaw(:); Response(:,1)])];

%Setup constraint data
[X,Y]   = localAddOpenEnds(XRaw,YRaw,OpenEnd,tRange);
if this.isLowerBound, 
   Width = -1;
else
   Width = 1;
end

%Create parametric lines for all segments
Slope = [diff(X,[],2), diff(Y,[],2)];
%Useful constants
nSignal = size(Response,2)-1;
nEdge   = size(X,1);
c       = nan(nEdge,nSignal);
for iEdge = 1:nEdge
   %Only check points that fall under edge
   ir = (X(iEdge,1) <= Response(:,1)) & (Response(:,1) <= X(iEdge,2));
   if any(ir)
      %Compute distance parametrically along edge
      r = (Response(ir,1)-X(iEdge,1))/Slope(iEdge,1);
      %Compute corresponding y-coordinate on edge
      y = (Y(iEdge,1)+r*Slope(iEdge,2))*ones(1,nSignal);
      %Now compute signed distance to edge and store maximum
      c(iEdge,:) = max( Width*(Response(ir,2:end)-y),[],1 );
   else
      %Signal(s) do not fall under edge, assume fully feasible
      c(iEdge,:) = -1*inf(1,nSignal);
   end
end

% %Add asymptote constraint for end edge if edge extends to infinity
% if Response(end,1)>XRaw(end,1) && OpenEnd(2) 
%    %Find signal(s) under last edge
%    iR = Response(:,1) >= XRaw(end,1);
%    t = Response(iR,1);        %Time data
%    nt = numel(t);
%    y = Response(iR,2:end);    %Signal data 
%    
%    %Find line for extended last edge
%    Slope = [X(end,2)-X(end-1,1), Y(end,2)-Y(end-1,1)];
%    if abs(Slope(1)) > sqrt(eps)
%       %Last edge is not vertical
%       r = (t-X(end-1,1))/Slope(1);
%       yEdge = Y(end-1,1)+r*Slope(2);
%       %Compute energy in Edge, require Width*(eSignal-eEdge) < 0 for all t
%       dy     = (y - yEdge).^2;
%       eError = cumsum(repmat(diff(t),1,nSignal).*(dy(1:nt-1,:)+dy(2:nt,:)),1);
%       %Fit line to [t,log(1+e)] data
%       c(nEdge+1,:) = -1*inf(1,nSignal);
%    else
%       %Last edge is vertical, assume fully stable
%       c(nEdge+1,:) = -1*inf(1,nSignal);
%    end
% end

%--------------------------------------------------------------------------
function [X,Y] = localAddOpenEnds(X,Y,OpenEnd,tRange)
% Sub-function to add edge for any open ends.

R = tRange(2)-tRange(1);  %Make sure any projected edge is long enough
if (tRange(1) < X(1)) && OpenEnd(1)
   %Need to add edge at start
   Slope = [X(1,2)-X(1,1) Y(1,2)-Y(1,1)];
   X = [X(1)-R*Slope(1), X(1); X];
   Y = [Y(1)-R*Slope(2), Y(1); Y];
end
if (tRange(2) > X(end)) && OpenEnd(2)
   %Need to add edge at end
   Slope = [X(end,2)-X(end,1) Y(end,2)-Y(end,1)];
   X = [X; X(end) X(end)+R*Slope(1)];
   Y = [Y; Y(end) Y(end)+R*Slope(2)];
end