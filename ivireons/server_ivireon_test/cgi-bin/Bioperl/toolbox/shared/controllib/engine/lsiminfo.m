function s = lsiminfo(y,varargin)
%LSIMINFO  Computes linear response characteristics.
%
%   S = LSIMINFO(Y,T,YFINAL) takes the response data (T,Y) and a
%   steady-state value YFINAL and returns a structure S containing 
%   the following performance indicators:
%     * SettlingTime: settling time
%     * Min: min value of Y
%     * MinTime: time at which the min value is reached.
%     * Max: max value of Y
%     * MaxTime: time at which the max value is reached.
%
%   For SISO responses, T and Y are vectors with the same length NS.
%   For responses with NY outputs, you can specify Y as an NS-by-NY 
%   array and YFINAL as a NY-by-1 array.  LSIMINFO then returns an 
%   NY-by-1 structure array S of performance metrics for each output
%   channel.
%
%   S = LSIMINFO(Y,T) uses the last sample value of Y as steady-state  
%   value YFINAL.  S = LSIMINFO(Y) assumes T = 1:NS.
% 
%   S = LSIMINFO(...,'SettlingTimeThreshold',ST) lets you specify the
%   threshold ST used in the settling time calculation.  The response
%   has settled when the error |y(t) - YFINAL| becomes smaller than a
%   fraction ST of its peak value.  The default value is ST=0.02 (2%).
%
%   Example:
%      sys = tf([1 -1],[1 2 3 4]);
%      [y,t] = impulse(sys);
%      s = lsiminfo(y,t,0)  % final value is 0
%
%   See also LSIM, IMPULSE, INITIAL, STEPINFO, DYNAMICSYSTEM.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/02/08 22:46:21 $
if nargin==0
   ctrlMsgUtils.error('Controllib:general:OneOrMoreInputsRequired','lsiminfo','lsiminfo')
else
   % Parse input list and perform consistency checks
   try
      [y,t,yfinal,SettlingTimeThreshold,~,Ts] = ...
         utRespInfoCheck(y,varargin{:});
   catch ME
      throw(ME)
   end
end

% Loop over each I/O pair
sio = size(yfinal);
s = struct(...
   'SettlingTime',cell(sio),...
   'Min',[],...
   'MinTime',[],...
   'Max',[],...
   'MaxTime',[]);
for ct=1:prod(sio)
   s(ct) = LocalGetInfo(s(ct),y(:,ct),t,yfinal(ct),SettlingTimeThreshold,Ts);
end

%------------------ Local Functions -----------------------------

function s = LocalGetInfo(s,y,t,ydc,SettlingTimeThreshold,Ts)
% Computes step response metrics for SISO response

% Min and max of response
[s.Max,imax] = max(y);
s.MaxTime = t(imax);
[s.Min,imin] = min(y);
s.MinTime = t(imin);

% Rise time and settling time
if isfinite(ydc)
   % Settling time of converging response
   ns = length(t);
   err = abs(y-ydc);
   tol = SettlingTimeThreshold * max(err);
   iSettle = find(err>tol,1,'last');
   if isempty(iSettle)
      % Pure gain
      s.SettlingTime = 0;
   elseif iSettle==ns
      % Has not settled
      s.SettlingTime = NaN;
   elseif Ts==0
      % Interpolate for more accuracy
      ySettle = ydc + sign(y(iSettle)-ydc) * tol;
      s.SettlingTime = t(iSettle) + ...
         (t(iSettle)-t(iSettle+1))/(y(iSettle)-y(iSettle+1)) * (ySettle-y(iSettle));
   else
      % Discrete time
      s.SettlingTime = t(iSettle+1);
   end       
else
   % Unstable response or unknown steady state
   s.SettlingTime = NaN;
end
   
