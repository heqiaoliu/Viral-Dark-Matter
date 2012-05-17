function [kest,l,p,m,z] = kalman(sys,qn,rn,varargin)
%KALMAN  Kalman state estimator.
%
%   [KEST,L,P] = KALMAN(SYS,QN,RN,NN) designs a Kalman estimator KEST for
%   the continuous- or discrete-time plant SYS. For continuous-time plants
%      .
%      x = Ax + Bu + Gw            {State equation}
%      y = Cx + Du + Hw + v        {Measurements}
%
%   with known inputs u, process disturbances w, and measurement noise v,
%   KEST uses [u(t);y(t)] to generate optimal estimates y_e(t),x_e(t) of 
%   y(t),x(t) by:
%       .
%      x_e  = Ax_e + Bu + L (y - Cx_e - Du)
%
%      |y_e| = | C | x_e + | D | u
%      |x_e|   | I |       | 0 | 
%
%   KALMAN takes the state-space model SYS=SS(A,[B G],C,[D H]) and the 
%   covariance matrices:
%
%      QN = E{ww'},     RN = E{vv'},     NN = E{wv'}.
%
%   The row size of QN specifies the length of w and NN is set to 0 when 
%   omitted. KALMAN returns the estimator gain L and the steady-state error 
%   covariance P (solution of the associated Riccati equation).
%
%   [KEST,L,P] = KALMAN(SYS,QN,RN,NN,SENSORS,KNOWN) handles more general 
%   situations where
%      * Not all outputs of SYS are measured
%      * The disturbance inputs w are not the last inputs of SYS.
%   The index vectors SENSORS and KNOWN then specify which outputs y of SYS
%   are measured and which inputs u to SYS are known. All other inputs of
%   SYS are assumed stochastic.
%
%   For discrete-time plants, KALMAN can compute a "current" or "delayed"
%   Kalman estimator. The "current" estimator uses all measurements up to
%   y[n] to estimate x[n]. The "delayed" estimator uses only past 
%   measurements up to y[n-1] and is easier to embed in digital control 
%   loops. The equations of the current estimator:
%
%      x[n+1|n] = Ax[n|n-1] + Bu[n] + L (y[n] - Cx[n|n-1] - Du[n])
%      y[n|n]  =  Cx[n|n] + Du[n]
%      x[n|n]  =  x[n|n-1] + M (y[n] - Cx[n|n-1] - Du[n])
%    
%   The delayed estimator has the same state equation but outputs 
%   y[n|n-1] = Cx[n|n-1] + Du[n] and x[n|n-1]  instead of y[n|n] and
%   x[n|n].
%
%   [KEST,L,P,M,Z] = KALMAN(SYS,QN,RN,...,TYPE) specifies the estimator
%   type for discrete-time plants SYS. The string TYPE is either 'current'
%   (default) or 'delayed'. KALMAN returns the estimator and innovation 
%   gains L and M and the steady-state error covariances:
%
%       P = E{(x - x[n|n-1])(x - x[n|n-1])'}   (Riccati solution)
%       Z = E{(x - x[n|n])(x - x[n|n])'}
%
%   See also KALMD, ESTIM, LQGREG, LQG, SS, CARE, DARE.

%   Author(s): P. Gahinet  8-1-96
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.8 $  $Date: 2010/02/08 22:28:34 $
ni = nargin;
error(nargchk(3,7,ni))
if ndims(sys)>2
    ctrlMsgUtils.error('Control:general:RequiresSingleModel','kalman')
elseif hasdelay(sys),
   throw(ltipack.utNoDelaySupport('kalman',sys.Ts,'all'))
end

% Check properness
% RE: Cannot reduce to proper here because this alters the state vector
e = sys.e;
if ~isempty(e) && rcond(e)<eps,
   ctrlMsgUtils.error('Control:general:NotSupportedSingularE','kalman')
end

% Extract plant data
[a,bb,c,dd,ee,Ts] = dssdata(sys);
Nx = size(a,1);
[pd,md] = size(dd);

% Look for 'current' or 'delayed' flag
ix = find(strcmpi(varargin,'current') | strcmpi(varargin,'delayed'));
if isempty(ix)
   DiscreteType = 'current'; % y[n|n], x[n|n] are the filter's output
else
   DiscreteType = varargin{ix};   varargin(:,ix) = [];  ni = ni-1;
end

if ni==3 || isempty(varargin{1}) || isequal(varargin{1},0),
    nn = zeros(size(qn,1),size(rn,1));
else
    nn = varargin{1};
end
    
% Validate Qn,Rn,Nn
[Nw,Nw2] = size(qn);
[Ny,Ny2] = size(rn);
Nu = md-Nw;
if Nw~=Nw2 || Nw>md || ~isreal(qn)
   ctrlMsgUtils.error('Control:design:kalman2','QN',md)
elseif Ny~=Ny2 || Ny>pd || ~isreal(rn)
   ctrlMsgUtils.error('Control:design:kalman2','RN',pd)
elseif Ny==0,
   ctrlMsgUtils.error('Control:design:kalman1')
elseif ni<5 && Ny~=pd
   ctrlMsgUtils.error('Control:design:kalman3')
elseif ~isequal(size(nn),[Nw Ny]) || ~isreal(nn)
   ctrlMsgUtils.error('Control:design:kalman4')
elseif norm(qn'-qn,1) > 100*eps*norm(qn,1),
   ctrlMsgUtils.warning('Control:design:MakeSymmetric','kalman(SYS,Qn,Rn,Nn)','Qn','Qn','Qn')
elseif norm(rn'-rn,1) > 100*eps*norm(rn,1),
   ctrlMsgUtils.warning('Control:design:MakeSymmetric','kalman(SYS,Qn,Rn,Nn)','Rn','Rn','Rn')
end

% Eliminate outputs that are not sensors
if ni<5    
   sensors = 1:pd;
else
   sensors = varargin{2};
   if any(sensors<=0) || any(sensors>pd),
      ctrlMsgUtils.error('Control:general:IndexOutOfRange','kalman(SYS,QN,RN,NN,SENSORS,...)','SENSORS')
   elseif length(sensors)~=Ny,
      ctrlMsgUtils.error('Control:design:kalman6')
   end
end
c = c(sensors,:);  dd = dd(sensors,:);

% Extract B,G,D,H
if ni<6
   % Stochastic inputs w are the last Nw=SIZE(Qn,2) inputs
   % and known inputs u are the remaining ones.
   known = 1:Nu;
else
   known = varargin{3};
   if any(known<=0) || any(known>md),
      ctrlMsgUtils.error('Control:general:IndexOutOfRange','kalman(SYS,QN,RN,NN,SENSORS,KNOWN)','KNOWN')
   elseif length(known)~=Nu,
      ctrlMsgUtils.error('Control:design:kalman5')
   end
end
stoch = 1:md;
stoch(known) = [];
b = bb(:,known);   d = dd(:,known);
g = bb(:,stoch);   h = dd(:,stoch);

% Derive reduced matrices
%
%  [Qb  Nb]     [ G  0 ] [ Qn  Nn ] [ G  0 ]'
%  [      ]  =  [      ] [        ] [      ]
%  [Nb' Rb]     [ H  I ] [ Nn  Rn ] [ H  I ]
%
% First derive equivalent covariance matrices for the auxiliary 
% measurement noise vt := Hw+v
hn = h * nn;
rb = rn  + hn + hn' + h * qn * h';
qb = g * qn * g';
nb = g * (qn * h' + nn);

% Enforce symmetry and check positivity
qb = (qb+qb')/2;
rb = (rb+rb')/2;
vr = real(eig(rb));
vqnr = real(eig([qb nb;nb' rb]));
if min(vr)<0 || (Ts==0 && min(vr)==0),
   ctrlMsgUtils.error('Control:design:kalman7')
elseif min(vqnr)<-1e2*eps*max(0,max(vqnr)),
   ctrlMsgUtils.warning('Control:design:MustBePositiveDefinite','[G 0;H I]*[Qn Nn;Nn'' Rn]*[G 0;H I]''','kalman')
end

% Solve Riccati equation
if Nx==0,
   p = [];
   k = zeros(Ny,0);
   report = 0;
elseif Ts==0,
   % Call CARE for continuous case
   [p,~,k,report] = care(a',c',qb,rb,nb,ee');
else
   % Call DARE for discrete case
   [p,~,k,report] = dare(a',c',qb,rb,nb,ee');
end

% Handle failure
if report<0
   ctrlMsgUtils.error('Control:design:kalman8')
end

% Build Kalman estimator (Ae,Be,Ce,De)
l = k';
ae = a-l*c;
be = [b-l*d , l];
if Ts==0,
   % Continuous state estimator
   %      .                             |u|
   %     x_e  = [A-LC] x_e + [B-LD , L] |y|
   %
   %    |y_e| = [C] x_e + [D 0] |u|
   %    |x_e| = [I]       [0 0] |y|
   m = [];
   z = [];
   ce = [c ; eye(Nx)];
   de = [d zeros(Ny);zeros(Nx,Nu+Ny)];
else
   % Discrete state estimator:
   %                                             |u[n]|
   %    x[n+1|n] = [A-LC] x[n|n-1] + [B-LD , L]  |y[n]|
   %
   %    L = (APC'+Nb) / (CPC'+Rb)
   %
   % where P = solution of DARE
   m = p*c'/(rb+c*p*c');  %  M = PC'/ (CPC'+Rb)
   z = p-m*(c*p);         % Z = (I-MC)*P
   z = (z+z')/2;
   if strcmpi(DiscreteType,'current')
      % "current" estimator
      %    |y[n|n]| = [(I-CM)C] x[n|n-1] + [(I-CM)D  CM]  |u[n]|
      %    |x[n|n]| = [ I-MC  ]            [ -MD      M]  |y[n]|
      cm = c*m;
      icm = eye(Ny)-cm;
      ce = [icm*c ; eye(Nx)-m*c];
      de = [icm*d cm;-m*d m];
   else
      % "delayed" estimator
      %    |y[n|n-1]| = [   C   ] x[n|n-1] + [D   0]  |u[n]|
      %    |x[n|n-1]| = [   I   ]            [0   0]  |y[n]|
      ce = [c ; eye(Nx)];
      de = [d zeros(Ny);zeros(Nx,Nu+Ny)];
   end
end

% Build estimator
kest = ss(ae,be,ce,de,Ts,'e',e);

% Set metadata
kest = estimMetaData(kest,sys,known,sensors);
