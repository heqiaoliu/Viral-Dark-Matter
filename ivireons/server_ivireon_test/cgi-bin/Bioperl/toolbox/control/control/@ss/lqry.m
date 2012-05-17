function [k,s,e] = lqry(sys,q,r,nn)
%LQRY  Linear-quadratic regulator design with output weighting.
%
%   [K,S,E] = LQRY(SYS,Q,R,N) calculates the optimal gain matrix K 
%   such that: 
%
%     * if SYS is a continuous-time system, the state-feedback law  
%       u = -Kx  minimizes the cost function
%
%             J = Integral {y'Qy + u'Ru + 2*y'Nu} dt
%                                       .
%       subject to the system dynamics  x = Ax + Bu,  y = Cx + Du
%
%     * if SYS is a discrete-time system, u[n] = -Kx[n] minimizes 
%
%             J = Sum {y'Qy + u'Ru + 2*y'Nu}
%
%       subject to  x[n+1] = Ax[n] + Bu[n],   y[n] = Cx[n] + Du[n].
%                
%   The matrix N is set to zero when omitted.  Also returned are the
%   the solution S of the associated algebraic Riccati equation and 
%   the closed-loop eigenvalues E = EIG(A-B*K).
%
%   See also LQR, LQGREG, LQG, CARE, DARE.

%   J.N. Little 7-11-88
%   Revised: 7-18-90 Clay M. Thompson, P. Gahinet 7-24-96
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2010/02/08 22:28:42 $

ni = nargin;
error(nargchk(3,4,ni))
if ndims(sys)>2
   ctrlMsgUtils.error('Control:general:RequiresSingleModel','lqry')
elseif hasdelay(sys),
   throw(ltipack.utNoDelaySupport('lqry',sys.Ts,'all'))
end
if ni==3 || isempty(nn) || isequal(nn,0),
   nn = zeros(size(q,1),size(r,1));
end

% Check properness
% RE: Cannot reduce to proper here because this alters the state vector
e = sys.e;
if ~isempty(e) && rcond(e)<eps,
   ctrlMsgUtils.error('Control:general:NotSupportedSingularE','lqry')
end

% Extract system data
[a,b,c,d,ee,Ts] = dssdata(sys);
[Ny,Nu] = size(d);

% Check dimensions and symmetry
if any(size(q)~=Ny),
   ctrlMsgUtils.error('Control:design:lqry1')
elseif any(size(r)~=Nu),
   ctrlMsgUtils.error('Control:design:lqry2')
elseif ~isequal(size(nn),[Ny Nu]),
   ctrlMsgUtils.error('Control:design:lqry3')
elseif ~(isreal(q) && isreal(r) && isreal(nn))
   ctrlMsgUtils.error('Control:design:lqr4','lqry')
elseif norm(q'-q,1) > 100*eps*norm(q,1),
   ctrlMsgUtils.warning('Control:design:MakeSymmetric','lqry(SYS,Q,R,N)','Q','Q','Q')
elseif norm(r'-r,1) > 100*eps*norm(r,1),
   ctrlMsgUtils.warning('Control:design:MakeSymmetric','lqry(SYS,Q,R,N)','R','R','R')
end

% Derive parameters of equivalent LQR problem
nd = nn' * d;
qq = c'*q*c;
rr = r + d'*q*d + nd + nd';
nn = c'*(q*d + nn);

% Enforce symmetry and check positivity
qq = (qq+qq')/2;
rr = (rr+rr')/2;
vr = real(eig(rr));
vqnr = real(eig([qq nn;nn' rr]));
if min(vr)<=0,
   ctrlMsgUtils.error('Control:design:lqry4')
elseif min(vqnr)<-1e2*eps*max(0,max(vqnr)),
   ctrlMsgUtils.warning('Control:design:MustBePositiveDefinite','[C D;0 I]''*[Q N;N'' R]*[C D;0 I]','lqry')
end


% Perform synthesis
if Ts==0,
   % Continuous time: call CARE
   [s,e,k,report] = care(a,b,qq,rr,nn,ee);
else
   % Discrete time: call DARE
   [s,e,k,report] = dare(a,b,qq,rr,nn,ee,'report');
end

% Handle failure
if report<0
   ctrlMsgUtils.error('Control:design:lqry5')
end

if ~isequal(ee,eye(size(a))),
   s = ee'*s*ee;
   s = (s+s')/2;
end
