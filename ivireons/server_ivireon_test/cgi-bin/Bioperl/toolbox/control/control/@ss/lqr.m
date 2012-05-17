function [K,S,E] = lqr(sys,q,r,varargin)
%LQR  Linear-quadratic regulator design for state space systems.
%
%   [K,S,E] = LQR(SYS,Q,R,N) calculates the optimal gain matrix K
%   such that:
%
%     * For a continuous-time state-space model SYS, the state-feedback
%       law u = -Kx  minimizes the cost function
%
%             J = Integral {x'Qx + u'Ru + 2*x'Nu} dt
%
%       subject to the system dynamics  dx/dt = Ax + Bu
%
%     * For a discrete-time state-space model SYS, u[n] = -Kx[n] minimizes
%
%             J = Sum {x'Qx + u'Ru + 2*x'Nu}
%
%       subject to  x[n+1] = Ax[n] + Bu[n].
%
%   The matrix N is set to zero when omitted.  Also returned are the
%   the solution S of the associated algebraic Riccati equation and
%   the closed-loop eigenvalues E = EIG(A-B*K).
%
%   [K,S,E] = LQR(A,B,Q,R,N) is an equivalent syntax for continuous-time
%   models with dynamics  dx/dt = Ax + Bu
%
%   See also DLQR, LQRY, LQI, LQGREG, LQGTRACK, LQG, CARE, DARE.

%   Author(s): J.N. Little 4-21-85
%   Revised    P. Gahinet  7-24-96
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2010/02/08 22:28:41 $
ni = nargin;
error(nargchk(3,4,ni))
if ndims(sys)>2
   ctrlMsgUtils.error('Control:general:RequiresSingleModel','lqr')
elseif hasdelay(sys),
   throw(ltipack.utNoDelaySupport('lqr',sys.Ts,'all'))
end

% Check properness
% RE: Cannot reduce to proper here because this alters the state vector
e = sys.e;
if ~isempty(e) && rcond(e)<eps,
   ctrlMsgUtils.error('Control:general:NotSupportedSingularE','lqr')
end

% Extract system data
[a,b,~,~,~,Ts] = dssdata(sys);
if ni==4
   nn = varargin{1};
   if isempty(nn) || isequal(nn,0),
      nn = zeros(size(b));
   end
else
   nn = zeros(size(b));
end

% Check dimensions and symmetry
Nx = size(a,1);
Nu = size(b,2);
if ~isequal(size(q),[Nx Nx])
   ctrlMsgUtils.error('Control:design:lqr2','lqr','A','Q')
elseif ~isequal(size(r),[Nu Nu])
   ctrlMsgUtils.error('Control:design:lqr3','lqr')
elseif ~isequal(size(nn),[Nx Nu]),
   ctrlMsgUtils.error('Control:design:lqr2','lqr','B','N')
elseif ~(isreal(q) && isreal(r) && isreal(nn))
   ctrlMsgUtils.error('Control:design:lqr4','lqr')
elseif norm(q'-q,1) > 100*eps*norm(q,1),
   ctrlMsgUtils.warning('Control:design:MakeSymmetric','lqr(...,Q,R,N)','Q','Q','Q')
elseif norm(r'-r,1) > 100*eps*norm(r,1),
   ctrlMsgUtils.warning('Control:design:MakeSymmetric','lqr(...,Q,R,N)','R','R','R')
end

% Enforce symmetry and check positivity
q = (q+q')/2;
r = (r+r')/2;
vr = eig(r);
vqnr = eig([q nn;nn' r]);
if min(vr)<=0,
   ctrlMsgUtils.error('Control:design:lqr3','lqr')
elseif min(vqnr)<-1e2*eps*max(0,max(vqnr)),
   ctrlMsgUtils.warning('Control:design:MustBePositiveDefinite','[Q N;N'' R]','lqr')
end

if Ts==0
   % Call CARE
   [S,E,K,report] = care(a,b,q,r,nn,e);
else
   % Call DARE
   [S,E,K,report] = dare(a,b,q,r,nn,e);
end

% Handle failure
if report<0
   ctrlMsgUtils.error('Control:design:lqr5')
end

if ~isempty(e)
   S = e'*S*e;
   S = (S+S')/2;
end
