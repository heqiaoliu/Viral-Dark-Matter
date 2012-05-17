function [Dsim,dt,tf,SimInfo] = trespSetUp(D,RespType,dt,tf,varargin)
% Build discrete models for independent simulation of each input channel.

%	 Author: P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:07 $

if D.Ts==0
   % Continuous-time case: redirect to @ssdata implementation
   [Dsim,dt,tf,SimInfo] = ...
      trespSetUp(LocalConvert2SS(D),RespType,dt,tf,[]);
   
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
Dtf = ltipack.tfdata({},{},0);
Dss = ltipack.ssdata.array([nu 1]);
for j=1:nu
   Dtf.num = D.num(:,j);
   Dtf.den = D.den(:,j);
   id = min(iod(:,j));
   od = iod(:,j)-id;
   Dtf.Delay.Input = id;
   Dtf.Delay.Output = od;
   Dtf.Delay.IO = zeros(ny,1);
   Dss(j,1) = ss(Dtf);
end
