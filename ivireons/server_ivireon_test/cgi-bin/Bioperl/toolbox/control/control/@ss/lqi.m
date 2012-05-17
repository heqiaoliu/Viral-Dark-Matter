function [K,S,E] = lqi(sys,Q,R,N)
%LQI  Linear-Quadratic-Integral control.
%
%   LQI computes an optimal state-feedback control law for the tracking
%   loop shown below. For a plant SYS with state-space equations
%   dx/dt = Ax + Bu, y = Cx + Du, or their discrete-time counterpart, the
%   state-feedback control is of the form u = - K [x; xi] where xi is the
%   integrator output. This control law ensures that the output y tracks
%   the reference command r. For MIMO systems, the number of integrators is
%   equal to the dimension of the output y.
%
%
%                                      .---------------------.
%                                   x  |    .---.            | x
%                                      '--->|   |            |
%              e = r-y  .----------.        |-K |        .---'---.
%     r ---->O----------|Integrator|------->|   |------->|  SYS  |-----> y
%            ^          '----------'  xi    '---'   u    '-------'  |
%            |-                                                     |
%            |                                                      |
%            '------------------------------------------------------'
%
%   [K,S,E] = lqi(SYS,Q,R,N) calculates the optimal gain matrix K given a
%   state-space model SYS of the plant and weighting matrices Q,R,N. The
%   control law u = -K z = -K [x;xi] minimizes the cost function
%
%             J(u) = Integral {z'Qz + u'Ru + 2*z'Nu} dt
%
%   in continuous time or
%
%             J(u) = Sum {z'Qz + u'Ru + 2*z'Nu}
%
%   in discrete time. In discrete time the integrator output xi is computed
%   using the forward Euler formula: xi[n+1] = xi[n] + Ts*(r[n] - y[n])
%   where Ts is the sampling time of SYS.
%
%   The matrix N is set to zero when omitted. LQI also returns the solution
%   S of the associated algebraic Riccati equation and the closed-loop
%   eigenvalues E.
%
%   See also LQR, LQGREG, LQGTRACK, LQG, CARE, DARE.

%   Author: Murad Abu-Khalaf Feb 29, 2008
%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2010/02/08 22:28:40 $

ni = nargin;
error(nargchk(3,4,ni));

if ndims(sys)>2
    ctrlMsgUtils.error('Control:general:RequiresSingleModel','lqi')
elseif hasdelay(sys)
    throw(ltipack.utNoDelaySupport('lqi',sys.Ts,'all'))
end

% Extract system data
[A,B,C,D,~,Ts] = dssdata(sys);  

% Check properness
% RE: Cannot reduce to proper here because this alters the state vector
e = sys.e;
if ~isempty(e) && rcond(e)<eps,
    ctrlMsgUtils.error('Control:general:NotSupportedSingularE','lqi')
end

% Get the single model dimensions
[ny,nu] = size(sys);
nx = size(A,1);

% Default N to zeros, unless otherwise specified.
if ni<4 || isempty(N) || isequal(N,0),
    N = zeros(nx+ny,nu);
end

% Check the dimensions of Q, R and N matrices
if ~all(size(Q)==nx+ny)
    ctrlMsgUtils.error('Control:design:lqi2','Q',nx+ny,nx+ny)
elseif ~all(size(R)==nu)
    ctrlMsgUtils.error('Control:design:lqi2','R',nu,nu)
elseif ~isequal(size(N),[nx+ny nu]),
    ctrlMsgUtils.error('Control:design:lqi2','N',nx+ny,nu)
elseif ~(isreal(Q) && isreal(R) && isreal(N))
   ctrlMsgUtils.error('Control:design:lqi4','lqi')
elseif norm(Q'-Q,1) > 100*eps*norm(Q,1),
   ctrlMsgUtils.warning('Control:design:MakeSymmetric','lqi(...,Q,R,N)','Q','Q','Q')
elseif norm(R'-R,1) > 100*eps*norm(R,1),
   ctrlMsgUtils.warning('Control:design:MakeSymmetric','lqi(...,Q,R,N)','R','R','R')
end

% Enforce symmetry and check positivity
Q = (Q+Q')/2;
R = (R+R')/2;
vr = eig(R);
vqnr = eig([Q N;N' R]);
if min(vr)<=0,
    ctrlMsgUtils.error('Control:design:lqi1')
elseif min(vqnr)<-1e2*eps*max(0,max(vqnr)),
    ctrlMsgUtils.warning('Control:design:MustBePositiveDefinite','[Q N;N'' R]','lqi')
end

% Form the augmented system with an integrator.
if ~isempty(e)
    e = blkdiag(e,eye(ny));
end

if Ts==0
    Aa = [A zeros(nx,ny); -C zeros(ny,ny)];
    Ba = [B ; -D];    
    [S,E,K,report] = care(Aa,Ba,Q,R,N,e);
else    
    % Discrete-time integrator based on Forward Euler
    Aa = [A zeros(nx,ny); -C*abs(Ts) eye(ny,ny)];
    Ba = [B ; -D*abs(Ts)];
    [S,E,K,report] = dare(Aa,Ba,Q,R,N,e);    
end

% Handle failure
if report<0
   ctrlMsgUtils.error('Control:design:lqi3');
end

if ~isempty(e)
   S = e'*S*e;    % This is the value of the optimal control problem of the 
                  % system x = E\Ax + E\Bu  
   S = (S+S')/2;  
end
