function [s,extra] = stepinfo(y,varargin)
%STEPINFO  Computes step response characteristics.
%
%   S = STEPINFO(Y,T,YFINAL) takes step response data (T,Y) and a
%   steady-state value YFINAL and returns a structure S containing 
%   the following performance indicators:
%     * RiseTime: rise time
%     * SettlingTime: settling time
%     * SettlingMin: min value of Y once the response has risen
%     * SettlingMax: max value of Y once the response has risen
%     * Overshoot: percentage overshoot (relative to YFINAL)
%     * Undershoot: percentage undershoot
%     * Peak: peak absolute value of Y
%     * PeakTime: time at which this peak is reached.
%
%   For SISO responses, T and Y are vectors with the same length NS.
%   For systems with NU inputs and NY outputs, you can specify Y as
%   an NS-by-NY-by-NU array (see STEP) and YFINAL as an NY-by-NU array.
%   STEPINFO then returns a NY-by-NU structure array S of performance
%   metrics for each I/O pair.
%
%   S = STEPINFO(Y,T) uses the last sample value of Y as steady-state  
%   value YFINAL.  S = STEPINFO(Y) assumes T = 1:NS.
%
%   S = STEPINFO(SYS) computes the step response characteristics for
%   an LTI model SYS (see TF, ZPK, or SS for details). 
% 
%   S = STEPINFO(...,'SettlingTimeThreshold',ST) lets you specify the
%   threshold ST used in the settling time calculation.  The response
%   has settled when the error |y(t) - YFINAL| becomes smaller than a
%   fraction ST of its peak value.  The default value is ST=0.02 (2%).
% 
%   S = STEPINFO(...,'RiseTimeLimits',RT) lets you specify the lower 
%   and upper thresholds used in the rise time calculation.  By default, 
%   the rise time is the time the response takes to rise from 10% to 90%  
%   of the steady-state value (RT=[0.1 0.9]).  Note that RT(2) is also 
%   used to calculate SettlingMin and SettlingMax.
%
%   Example:
%      sys = rss(5);
%      s = stepinfo(sys,'RiseTimeLimits',[0.05,0.95])
%
%   See also STEP, LSIMINFO, DYNAMICSYSTEM.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/02/08 22:46:22 $
if nargin==0
   ctrlMsgUtils.error('Controllib:general:OneOrMoreInputsRequired','stepinfo','stepinfo')
else
   % Parse input list and perform consistency checks
   try
      [y,t,yfinal,SettlingTimeThreshold,RiseTimeLims,Ts] = ...
         utRespInfoCheck(y,varargin{:});
   catch E
      throw(E)
   end
end

% Loop over each I/O pair
sio = size(yfinal);
s = struct(...
   'RiseTime',cell(sio),...
   'SettlingTime',[],...
   'SettlingMin',[],...
   'SettlingMax',[],...
   'Overshoot',[],...
   'Undershoot',[],...
   'Peak',[],...
   'PeakTime',[]);
extra = struct(...
   'RiseTimeLow',cell(sio),...
   'RiseTimeHigh',[]);
for ct=1:prod(sio)
   [s(ct),extra(ct)] = LocalGetInfo(s(ct),extra(ct),...
      y(:,ct),t,yfinal(ct),SettlingTimeThreshold,RiseTimeLims,Ts);
end

%------------------ Local Functions -----------------------------

function [s,xt] = LocalGetInfo(s,xt,y,t,yf,SettlingTimeThreshold,RiseTimeLims,Ts)
% Computes step response metrics for SISO response
% YF = final value

% Rise time and settling time
if isfinite(yf)
   % Converging response
   ns = length(t);
   
   % Peak response
   [s.Peak,ipeak] = max(abs(y));
   s.PeakTime = t(ipeak);

   % Get time TLOW of first crossing of y = y0 + RiseTimeLims(1)*(yf-y0)
   yLow = y(1) + RiseTimeLims(1)*(yf-y(1));
   iLow = 1+find((y(1:ns-1)-yLow).*(y(2:ns)-yLow)<=0,1);
   if isempty(iLow)
      % Has not yet reached RiseTimeLims(1) level
      tLow = NaN;
   elseif Ts==0 && iLow>1 && y(iLow)~=y(iLow-1)
      % Interpolate for more accuracy
      tLow = t(iLow) + (t(iLow)-t(iLow-1))/(y(iLow)-y(iLow-1)) * (yLow-y(iLow));
   else
      % Discrete time or pure gain
      tLow = t(iLow);
   end
   
   % Get time THIGH of first crossing of y = y0 + RiseTimeLims(2)*(yf-y0)
   yHigh = y(1) + RiseTimeLims(2)*(yf-y(1));
   iHigh = 1+find((y(1:ns-1)-yHigh).*(y(2:ns)-yHigh)<=0,1);
   if isempty(iHigh)
      % Has not yet reached RiseTimeLims(2) level
      tHigh = NaN;
      s.SettlingMin = NaN;
      s.SettlingMax = NaN;
   else
      if Ts==0 && iHigh>1 && y(iHigh)~=y(iHigh-1)
         % Interpolate for more accuracy
         tHigh = t(iHigh) + (t(iHigh)-t(iHigh-1))/(y(iHigh)-y(iHigh-1)) * (yHigh-y(iHigh));
      else
         % Discrete time or pure gain
         tHigh = t(iHigh);
      end
      yRisen = y(iHigh:end);
      s.SettlingMin = min(yRisen);
      s.SettlingMax = max(yRisen);
   end
   
   % Rise time
   s.RiseTime = tHigh - tLow;
   xt.RiseTimeLow = tLow;
   xt.RiseTimeHigh = tHigh;
   
   % Settling Time
   err = abs(y-yf);
   tol = SettlingTimeThreshold * max(err);
   iSettle = find(err>tol,1,'last');
   if isempty(iSettle)
      % Pure gain
      s.SettlingTime = 0;
   elseif iSettle==ns
      % Has not settled
      s.SettlingTime = NaN;
   elseif Ts==0 && y(iSettle)~=y(iSettle+1)
      % Interpolate for more accuracy
      ySettle = yf + sign(y(iSettle)-yf) * tol;
      s.SettlingTime = t(iSettle) + ...
         (t(iSettle)-t(iSettle+1))/(y(iSettle)-y(iSettle+1)) * (ySettle-y(iSettle));
   else
      % Discrete time or pure gain
      s.SettlingTime = t(iSettle+1);
   end
   
   % Overshoot and undershoot
   if yf==0
      s.Overshoot = Inf;
      if all(y>=0)
         s.Undershoot = 0;
      else
         s.Undershoot = Inf;
      end
   else
      yrel = y/yf;
      s.Overshoot = 100 * max(0,max(yrel-1));
      s.Undershoot = -100 * min(0,min(yrel));
   end
      
else
   % Unstable response or unknown steady state
   s.RiseTime = NaN;
   s.SettlingTime = NaN;
   s.SettlingMin = NaN;
   s.SettlingMax = NaN;
   s.Overshoot = NaN;
   s.Undershoot = NaN;
   s.Peak = Inf;
   s.PeakTime = Inf;
   xt.RiseTimeLow = Inf;
   xt.RiseTimeHigh = Inf;

end
   
