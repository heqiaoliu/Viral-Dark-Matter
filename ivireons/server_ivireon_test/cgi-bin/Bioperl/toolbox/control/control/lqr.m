function [K,S,E] = lqr(a,b,q,r,varargin)
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
%   $Revision: 1.13.4.9 $  $Date: 2010/02/08 22:24:56 $
ni = nargin;
if ni>0 && ~isa(a,'double')
   ctrlMsgUtils.error('Control:general:NotSupportedModelsofClass','lqr',class(a));
end
error(nargchk(4,5,ni));

% Check dimensions
error(abcdchk(a,b));

try
   [K,S,E] = lqr(ss(a,b,[],[]),q,r,varargin{:});
catch ME
   throw(ME);
end
