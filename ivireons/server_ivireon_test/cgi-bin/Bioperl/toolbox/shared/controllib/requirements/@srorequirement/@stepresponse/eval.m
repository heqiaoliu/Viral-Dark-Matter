function c = eval(this,Response)
% Evaluates time response requirement for given signal.
%
% Inputs:
%          this      - a srorequirement.stepresponse object.
%          Response  - An n-by-m matrix with the signal to evaluate, the first
%                      column is the time vector, subsequent columns the response.
% Outputs:
%          c - an n-by-m matrix of doubles giving the maximum signed distance
%          of each signal to each edge of the requirement. A negative value
%          indicates a feasible point.

% Author(s): A. Stothert 15-Jan-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/03/26 17:50:10 $

if isempty(Response)
    c = [];
    return
end

if isa(Response,'lti')
   [y,t] = step(Response);
   Response = [t,y];
end

if size(Response,1)==1 && any(isnan(Response))
    % Trying to evaluate invalid response
    c = 1e8 + 1i;
    return
end

%Retrieve basic constraint data
XAll    = this.Data.getData('xdata');
YAll    = this.Data.getData('ydata');
OpenEnd = this.Data.getData('OpenEnd');
tRange  = [...
    min([XAll(:); Response(:,1)]), ...
    max([YAll(:); Response(:,1)])];

%Split Data into upper and lower bounds
XRaw{1} = XAll(1:2,:);   %Upper bound
YRaw{1} = YAll(1:2,:);
XRaw{2} = XAll(3:5,:);   %Lower bound
YRaw{2} = YAll(3:5,:);
Width   = {1, -1};       %Upper bound, lower bound

%Useful constants
nSignal = size(Response,2)-1;
nEdge   = size(XAll,1) + 2*sum(OpenEnd);
c       = nan(nEdge,nSignal);                     %Vector with violatiosn for all edges
cOffset = {0,size(XRaw{1},1)+2*sum(OpenEnd)-1};   %c offset index for upper & lower bound

%Loop over upper and lower bounds computing violations for each
for ct=1:2
    %Setup constraint data
    [X,Y] = localAddOpenEnds(XRaw{ct},YRaw{ct},OpenEnd,tRange);
    ctWidth = Width{ct};
    
    %Create parametric lines for all segments
    Slope = [diff(X,[],2), diff(Y,[],2)];
    for iEdge = 1:size(X,1)
        %Only check points that fall under edge
        ir = (X(iEdge,1) <= Response(:,1)) & (Response(:,1) <= X(iEdge,2));
        if any(ir)
            %Compute distance parametrically along edge
            r = (Response(ir,1)-X(iEdge,1))/Slope(iEdge,1);
            %Compute corresponding y-coordinate on edge
            y = (Y(iEdge,1)+r*Slope(iEdge,2))*ones(1,nSignal);
            %Now compute signed distance to edge and store maximum
            c(iEdge+cOffset{ct},:) = max( ctWidth*(Response(ir,2:end)-y),[],1 );
        else
            %Signal(s) do not fall under edge, assume fully feasible
            c(iEdge+cOffset{ct},:) = -1*inf(1,nSignal);
        end
    end
end
end

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
end