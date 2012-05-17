function rsys = reg(sys,K,L,sensors,known,controls)
%REG  Form regulator given state-feedback and estimator gains.
%
%   RSYS = REG(SYS,K,L) produces an observer-based regulator RSYS
%   for the state-space system SYS, assuming all inputs of SYS are 
%   controls and all outputs are measured.  The matrices K and L 
%   specify the state-feedback and observer gains.  For
%              .
%       SYS:   x = Ax + Bu ,   y = Cx + Du 
%
%   the resulting regulator is 
%        .
%       x_e = [A-BK-LC+LDK] x_e + Ly
%         u = -K x_e  
%
%   This regulator should be connected to the plant using positive
%   feedback.  REG behaves similarly when applied to discrete-time 
%   systems.
%
%   RSYS = REG(SYS,K,L,SENSORS,KNOWN,CONTROLS) handles more 
%   general regulation problems where 
%     * the plant inputs consist of controls u, known inputs Ud, 
%       and stochastic inputs w, 
%     * only a subset y of the plant outputs are measured. 
%   The I/O subsets y, Ud, and u are specified by the index vectors
%   SENSORS, KNOWN, and CONTROLS.  The resulting regulator RSYS    
%   uses [Ud;y] as input to generate the commands u. 
%
%   You can use pole placement techniques (see PLACE) to design the
%   gains K and L, or alternatively use the LQ and Kalman gains 
%   produced by LQR/DLQR and KALMAN.
%
%   See also PLACE, LQR, DLQR, LQGREG, ESTIM, KALMAN, SS.

%   Clay M. Thompson 6-29-90
%   Revised: P. Gahinet  7-26-96
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2010/02/08 22:28:48 $

ni = nargin;
error(nargchk(3,6,ni))
if ndims(sys)>2
   ctrlMsgUtils.error('Control:general:RequiresSingleModel','reg')
elseif hasdelay(sys),
   throw(ltipack.utNoDelaySupport('reg',sys.Ts,'all'))
end

% Determine sensor outputs
[p,m] = size(sys);
Nx = order(sys);
if ni<4,
   sensors = 1:p;
elseif any(sensors<=0) || any(sensors>p),
   ctrlMsgUtils.error('Control:general:IndexOutOfRange','reg(SYS,K,L,SENSORS,...)','SENSORS')
end
Ny = length(sensors);

% Partition inputs into u,Ud,w
switch ni,
   case 5
      if any(known<=0) || any(known>m),
         ctrlMsgUtils.error('Control:general:IndexOutOfRange','reg(SYS,K,L,SENSORS,KNOWN,...)','KNOWN')
      end
      known = known(:);
      controls = (1:m)';
      controls(known) = [];
   case 6
      if any(controls<=0) || any(controls>m),
         ctrlMsgUtils.error('Control:general:IndexOutOfRange','reg(SYS,K,L,SENSORS,KNOWN,CONTROLS)','CONTROLS')
      elseif length(controls)+length(known)>m,
         ctrlMsgUtils.error('Control:design:reg1')
      end
      known = known(:);
      controls = controls(:);
   otherwise
      known = [];
      controls = (1:m)';
end
Nu = length(controls);

% Compute estimator
if ~isequal(size(L),[Nx Ny]),
   ctrlMsgUtils.error('Control:design:reg2')
end
est = estim(sys,L,sensors,[controls;known]);

% Close the loop
%
%      +-------| -K  |<---+
%   u  |                  |
%      |       +-----+    |
%      +------>|     |--- | ---> y_e
%   Ud ------->| EST |    |
%    y ------->|     |----+----> x_e
%              +-----+
%
if ~isequal(size(K),[Nu Nx]),
   ctrlMsgUtils.error('Control:design:reg3')
end
rsys = feedback(est,K,1:Nu,Ny+1:Ny+Nx);

kss = ss(-K);
if Nu>0,
   % Keep names of control channels
   if isempty(sys.InputName_)
      kss.OutputName = strseq('u',controls);
   else
      kss.OutputName = sys.InputName_(controls);
   end
   kss.OutputGroup = struct('Controls',1:Nu);
end

% Get rid of u,y_e and add gain K so that output is u = K x_e
iselect = {Ny+1:Ny+Nx , Nu+1:Nu+Ny+length(known)};
rsys = kss * subparen(rsys,iselect);

