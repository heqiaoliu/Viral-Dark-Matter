function c = eval(this,Response)
% Evaluates signaltracking requirement for given signal. Note this
% requirement can be either an objective or constraint.
%
% Inputs:
%          this      - a srorequirement.signaltracking object.
%          Response  - An nxm vector with the signal to evaluate, the first 
%                      column is the time vector.
% Outputs: 
%          c - a double giving the SSE of the Response when compared with
%          the signal defined by this requirements.
 
% Author(s): A. Stothert 25-Feb-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:57 $

if isempty(Response)
   c = []; 
   return
end

%Measured response
t = Response(:,1);
y = Response(:,2:end);

if length(t)==1 && isnan(t)
   % Sim failure
   c = 1e8 + i;
else
   %Reference
   tr = this.Data.getData('xdata');
   yr = this.Data.getData('ydata');
   wr = this.Data.getData('weight');

   % Merge the time bases
   tmin = max(t(1),tr(1));
   tmax = min(t(end),tr(end));
   ts = unique([t(t>=tmin & t<=tmax) ; tr(tr>=tmin & tr<=tmax)]);
   y = interp1(t,y,ts);
   yr = interp1(tr,yr,ts);
   if isempty(wr)
      wr = 1;
   else
      wr = interp1(tr,wr,ts);
   end
   % Estimate 1/T * int_0^T w(t) e(t)^2 dt
   e = (y-yr) * diag(1./max(abs(yr)));  % scaled error
   f = sum(e.^2,2) .* wr;
   ns = length(ts);
   c = sum( 0.5*(f(1:ns-1) + f(2:ns)).*diff(ts) );

   % Safeguard against instability
   if ~isfinite(c)
      % NaN value can arise when goes unstable
      c = 1e8 + i;
   elseif c>10
      c = 10*(1+log(c/10));
   end
end
