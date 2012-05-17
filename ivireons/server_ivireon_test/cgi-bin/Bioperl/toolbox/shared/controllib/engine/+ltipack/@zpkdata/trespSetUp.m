function [Dsim,dt,tf,SimInfo] = trespSetUp(D,RespType,dt,tf,varargin)
% Build discrete models for independent simulation of each input channel.

%	 Author: P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:34:01 $

if D.Ts==0
   % Continuous-time case: redirect to @ssdata implementation
   [Dsim,dt,tf,SimInfo] = ...
      trespSetUp(LocalConvert2SS(D),RespType,dt,tf,[]);
   SimInfo.XEnable = false;

else
   % Discrete-time case: simulate directly
   Dsim = D;

   % Allocate SimInfo struct
   SimInfo = struct(...
      'FinalValue',[],...     % anticipated final value (assuming convergence)
      'IC',[],...             % ignored
      'MaxSample',[],...      % max number of time steps in simulation
      'DivThreshold',[],...   % divergence threshold (|y|>DivThreshold -> diverged)
      'XMap',[]);             % ignored

   % When sim. horizon is undefined, save info about stability and DC value
   if isempty(tf)
      % Steady-state value estimate
      SimInfo.FinalValue = getFinalValue(D,RespType);
   end
end

%----------------- Local functions ------------------------------

function Dss = LocalConvert2SS(D)
% Converts each column to state space and determines adequate sample time
iod = getIODelay(D,'total');
[ny,nu] = size(iod);

% Convert each column to state space
Dzpk = ltipack.zpkdata({},{},[],0);
Dss = ltipack.ssdata.array([nu 1]);
for j=1:nu
   Dzpk.z = D.z(:,j);
   Dzpk.p = D.p(:,j);
   Dzpk.k = D.k(:,j);
   id = min(iod(:,j));
   od = iod(:,j)-id;
   Dzpk.Delay.Input = id;
   Dzpk.Delay.Output = od;
   Dzpk.Delay.IO = zeros(ny,1);
   Dss(j,1) = ss(Dzpk);
end
