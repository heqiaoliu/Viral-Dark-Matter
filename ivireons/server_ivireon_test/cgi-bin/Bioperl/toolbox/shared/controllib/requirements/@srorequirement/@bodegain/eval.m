function c = eval(this,Sys)
% EVAL method to evaluate bode gain requirement for a given system
%
% Inputs:
%          this - a srorequirement.bodegain object.
%          Sys  - An n-by-1  vector of Sys structures
% Outputs: 
%          c - an n-by-1 matrix of doubles giving the maximum signed distance 
%          of each signal to each edge of the requirement. A negative value 
%          indicates a feasible point. 

% Author(s): A. Stothert 06-Apr-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:26 $

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
   rV = localReshape(rV); 
   iV = localReshape(iV);
   if numel(wCrit) > 2
      [rVb,iVb,wb] = nyquist(Model,wCrit(2:end-1));
      rVb = localReshape(rVb); 
      iVb = localReshape(iVb);
      rV = [rV; rVb]; iV = [iV; iVb]; w = [w; wb];
   end
   FreqResponse = struct('real',rV,'imag',iV,'freq',w);
   mag = abs(rV+1i*iV);
else
   %Have frequency data 
   mag = abs(Sys.FreqResponse.real+1i*Sys.FreqResponse.imag);
   w = Sys.FreqResponse.freq;
end

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

%--------------------------------------------------------------------------
function x = localReshape(x)
%Helper function to convert output from Nyquist to single column of data

x = reshape(permute(x,[3 1 2]),size(x,3),size(x,2)*size(x,1));
