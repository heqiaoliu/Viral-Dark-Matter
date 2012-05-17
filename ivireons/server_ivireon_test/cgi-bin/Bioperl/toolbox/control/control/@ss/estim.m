function est = estim(sys,L,sensors,known)
%ESTIM  Form estimator given estimator gain.
%
%   EST = ESTIM(SYS,L) produces an estimator EST with gain L for
%   the outputs and states of the state-space model SYS, assuming 
%   all inputs of SYS are stochastic and all outputs are measured.
%   For continuous-time systems
%             .
%      SYS:   x = Ax + Bw ,   y = Cx + Dw   (with w stochastic),
% 
%   the estimator equations are
%        .
%        x_e   = [A-LC] x_e + Ly
%
%      | y_e | = | C | x_e 
%      | x_e |   | I |
%
%   and the outputs x_e(t) and y_e(t) of EST are estimates of x(t) 
%   and y(t)=Cx(t). For discrete-time systems
%
%      SYS:  x[n+1] = Ax[n] + Bw[n] , y[n] = Cx[n] + Dw[n]
%
%   the estimator has similar equations and its outputs y[n|n-1] and 
%   x[n|n-1] are estimates of y[n] and x[n] based on past measurements 
%   up to y[n-1].
%
%   EST = ESTIM(SYS,L,SENSORS,KNOWN) handles more general plants
%   SYS with both deterministic and stochastic inputs, and both 
%   measured and non-measured outputs.  The index vectors SENSORS 
%   and KNOWN specify which outputs y are measured and which inputs 
%   u are known, respectively.  The resulting estimator EST uses 
%   [u;y] as input to produce the estimates [y_e;x_e].  
%
%   You can use pole placement techniques (see PLACE) to design 
%   the estimator (observer) gain L, or use the Kalman filter gain
%   returned by KALMAN or KALMD.
%
%   See also PLACE, KALMAN, KALMD, REG, LQGREG, SS.

%   Clay M. Thompson 7-2-90
%   Revised: P. Gahinet 7-30-96
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $  $Date: 2010/02/08 22:28:31 $

ni = nargin;
error(nargchk(2,4,ni))
if ndims(sys)>2
   ctrlMsgUtils.error('Control:general:RequiresSingleModel','estim')
elseif hasdelay(sys)
   throw(ltipack.utNoDelaySupport('estim',sys.Ts,'all'))
end

% Extract state-space data
[a,b,c,d,~,Ts] = dssdata(sys);
Nx = size(a,1);
[pd,md] = size(d);

% Eliminate outputs that are not sensors
if ni<3,
   sensors = 1:pd;
elseif any(sensors<=0) || any(sensors>pd),
   ctrlMsgUtils.error('Control:general:IndexOutOfRange','estim(SYS,L,SENSORS,...)','SENSORS')
end
c = c(sensors,:);
d = d(sensors,:);
Ny = length(sensors);

% Check dimensions of L
if ~isequal(size(L),[Nx Ny]),
   ctrlMsgUtils.error('Control:design:estim1')
end

% Select known inputs
if ni<4,
   known = [];
elseif any(known<=0) || any(known>md),
    ctrlMsgUtils.error('Control:general:IndexOutOfRange','estim(SYS,L,SENSORS,KNOWN)','KNOWN')
end

% Extract matrices B and D
b = b(:,known);
d = d(:,known);
Nu = length(known);

% Get observer matrices
ae = a-L*c;
be = [b-L*d L];
ce = [c ; eye(Nx)];
de = [[d ; zeros(Nx,Nu)] , zeros(Nx+Ny,Ny)];

% Form resulting estimator system
est = ss(ae,be,ce,de,Ts,'e',get(sys,'e'));

% Set metadata
est = estimMetaData(est,sys,known,sensors);
