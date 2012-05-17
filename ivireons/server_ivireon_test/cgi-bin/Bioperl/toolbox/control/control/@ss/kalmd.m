function [kest,l,p,m,z] = kalmd(sys,qn,rn,Ts)
%KALMD  Discrete Kalman estimator for continuous-time plant.
%
%   [KEST,L,P,M,Z] = KALMD(SYS,Qn,Rn,Ts) computes a discrete Kalman 
%   estimator KEST for the continuous plant 
%        .
%        x = Ax + Bu + Gw      {State equation}
%        y = Cx + Du +  v      {Measurements}
%
%   with process and measurement noise
%
%     E{w} = E{v} = 0,  E{ww'} = Qn,  E{vv'} = Rn,  E{wv'} = 0.
%
%   The state-space model SYS specifies the plant data (A,[B G],C,[D 0]).
%   The continuous plant and covariance matrices (Q,R) are first 
%   discretized using the sample time Ts and zero-order hold approximation, 
%   and the discrete Kalman estimator for the resulting discrete plant is 
%   then calculated with KALMAN.
%
%   KALMD also returns the estimator gain L, innovation gain M, and the 
%   steady-state error covariances P and Z (type HELP KALMAN for details).
%
%   See also LQRD, KALMAN, LQGREG.

%   Author(s): Clay M. Thompson 7-18-90, P. Gahinet  8-1-96
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.8 $  $Date: 2010/02/08 22:28:35 $
ni = nargin;
error(nargchk(4,4,ni))
if ndims(sys)>2
   ctrlMsgUtils.error('Control:general:RequiresSingleModel','kalmd')
elseif hasdelay(sys),
   throw(ltipack.utNoDelaySupport('kalmd',sys.Ts,'all'))
end

% Extract plant data
try
   [a,bb,c,dd,tsp] = ssdata(sys);
catch %#ok<CTCH>
   ctrlMsgUtils.error('Control:general:NotSupportedSingularE','kalmd')
end
Nx = size(a,1);
[Ny,md] = size(dd);
if tsp~=0,
   ctrlMsgUtils.error('Control:design:kalmd1')
elseif Ny==0,
   ctrlMsgUtils.error('Control:design:kalmd2')
end

% Check symmetry and dimensions of Qn,Rn
[Nw,Nw2] = size(qn);
Nu = md-Nw;
if Nw~=Nw2 || Nw>md,
   ctrlMsgUtils.error('Control:design:kalmd3')
elseif any(size(rn)~=Ny),
   ctrlMsgUtils.error('Control:design:kalmd4')
elseif norm(qn'-qn,1) > 100*eps*norm(qn,1),
   ctrlMsgUtils.warning('Control:design:MakeSymmetric','kalmd(SYS,Qn,Rn,Ts)','Qn','Qn','Qn')
elseif norm(rn'-rn,1) > 100*eps*norm(rn,1),
   ctrlMsgUtils.warning('Control:design:MakeSymmetric','kalmd(SYS,Qn,Rn,Ts)','Rn','Rn','Rn')
end

% Extract B,G,D,H
b = bb(:,1:Nu);   d = dd(:,1:Nu);
g = bb(:,Nu+1:Nu+Nw);   h = dd(:,Nu+1:Nu+Nw);
if any(h(:)),
   ctrlMsgUtils.error('Control:design:kalmd5')
end

% Form G*Q*G', enforce symmetry and check positivity
qn = g * qn *g';
qn = (qn+qn')/2;
rn = (rn+rn')/2;
if min(real(eig(rn)))<=0,
   ctrlMsgUtils.error('Control:design:kalmd6')
end

% Discretize the state-space system.
[ad,bd] = c2d(a,b,Ts);

% Compute discrete equivalent of continuous noise
M = [-a  qn ; zeros(Nx) a'];
phi = expm(M*Ts);
phi12 = phi(1:Nx,Nx+1:2*Nx);
phi22 = phi(Nx+1:2*Nx,Nx+1:2*Nx);
Qd = phi22'*phi12;
Qd = (Qd+Qd')/2; % Make sure Qd is symmetric
Rd = rn/Ts;

% Call KALMAN on discretized plant/noise to derive KEST
sysd = ss(ad,[bd eye(Nx)],c,[d zeros(Ny,Nx)],Ts);
sysd.StateName = sys.StateName;
sysd.InputName = [sys.InputName(1:Nu);repmat({''},[Nx 1])];
sysd.OutputName_ = sys.OutputName_;
[kest,l,p,m,z] = kalman(sysd,Qd,Rd);
