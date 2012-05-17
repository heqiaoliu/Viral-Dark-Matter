function s = stepinfo(sys,varargin)
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
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:49:44 $
if numsys(sys)~=1
   ctrlMsgUtils.error('Control:general:RequiresSingleModel','stepinfo')
end
% REVISIT: define standard API for getting step response
% Simulate response
try
   [y,t] = timeresp(getPrivateData(sys),'step',[]);
catch E
   throw(E);
end
% Steady-state value
ns = length(t);
if nargin>1 && isnumeric(varargin{1})
   yf = varargin{1};
   varargin = varargin(2:end);
else
   % Use last sample value (set to final value by *RESP simulators)
   yf = permute(y(ns,:,:),[2 3 1]);
end
% Compute characteristics (remove last "final value" sample)
% Pass sample time to prevent interpolation in discrete time
% REVISIT: place Ts by flag indicating continuous vs. discrete
s = stepinfo(y(1:ns-1,:,:),t(1:ns-1),yf,'Ts',abs(sys.Ts),varargin{:});
