function c = eval(this,Sys)
% EVAL method to evaluate Singular Value gain requirement for a given system
%
% Inputs:
%          this - a srorequirement.svdgain object.
%          Sys  - An n-by-1  vector of Sys structures
% Outputs: 
%          c - an n-by-1 matrix of doubles giving the maximum signed distance 
%          of each signal to each edge of the requirement. A negative value 
%          indicates a feasible point. 

% Author(s): A. Stothert
%   Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:50:11 $

c = [];
if isempty(Sys)
   return
end

if isfield(Sys,'Model')
   Model = Sys.Model; 
   FreqResponse = Sys.FreqResponse;
else
   Model = Sys;
   FreqResponse = [];
end

%Retrieve constraint data
X = this.Data.getData('xData');
Y = this.Data.getData('yData');

if isempty(FreqResponse)
   %Need to compute frequency data, store data so can potentially reuse
   wCrit = [X(:,1); X(end)];
   wCrit = unitconv(wCrit,this.Data.getData('xUnits'),'rad/sec');
   [rV,iV,w] = nyquist(Model,{wCrit(1), wCrit(end)});
   if numel(wCrit) > 2
      [rVb,iVb,wb] = nyquist(Model,wCrit(2:end-1));
      rV = cat(3,rV,rVb); 
      iV = cat(3,iV,iVb); 
      w = [w; wb];
   end
   FreqResponse = struct('real',rV,'imag',iV,'freq',w);
else
   %Have frequency data 
   w = Sys.FreqResponse.freq;
end
mag = localGetSV(FreqResponse.real,FreqResponse.imag);

%Perform any unit conversions
if strcmpi(this.Data.getData('xUnits'),'hz')
   w = unitconv(w,'rad/sec','Hz');
end
if strcmpi(this.Data.getData('yUnits'),'db')
   mag = unitconv(mag,'abs','db');
end

%Form response vector
Response = [w(:), mag];

%Useful constants
nEdge   = this.Data.getEdgeCount;
nSignal = size(Response,2)-1;
c       = nan*zeros(nEdge,nSignal);
if this.isLowerBound, 
   Width = -1;
else
   Width = 1;
end

%Create parametric lines for all segments
if this.isSemiLogX
   %Frequency bound is in semilog mode
   Slope = [diff(log10(X),[],2), diff(Y,[],2)];
else
   Slope = [diff(X,[],2), diff(Y,[],2)];
end

for iEdge = 1:nEdge
   %Only check points that fall under edge
   ir = (X(iEdge,1) <= Response(:,1)) & (Response(:,1) <= X(iEdge,2));
   %Compute distance parametrically along edge
   if this.isSemiLogX
      r = (log10(Response(ir,1))-log10(X(iEdge,1)))/Slope(iEdge,1);
   else
      r = (Response(ir,1)-X(iEdge,1))/Slope(iEdge,1);
   end
   %Compute corresponding y-coordinate on edge
   y = (Y(iEdge,1)+r*Slope(iEdge,2))*ones(1,nSignal);
   %Now compute signed distance to edge and store maximum 
   c(iEdge,:) = max( Width*(Response(ir,2:end)-y) );
end

if isfield(Sys,'Model') && isempty(Sys.FreqResponse)
   Sys.FreqResponse = FreqResponse;
end
end

function sv = localGetSV(R,I)
%Form complex frequency response
H = R+1i*I;
sv = ltipack.getSV(H,0);

%Reshape SV which always has frequency as second dimension
sv = sv';
end

