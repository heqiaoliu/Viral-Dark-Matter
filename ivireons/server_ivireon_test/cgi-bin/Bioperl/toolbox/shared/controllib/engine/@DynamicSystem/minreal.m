function [sys,u] = minreal(sys,tol,dispflag)
%MINREAL  Minimal realization and pole-zero cancellation.
%
%   MSYS = MINREAL(SYS) produces, for a given LTI model SYS, an
%   equivalent model MSYS where all cancelling pole/zero pairs
%   or non minimal state dynamics are eliminated.  For state-space 
%   models, MINREAL produces a minimal realization MSYS of SYS where 
%   all uncontrollable or unobservable modes have been removed.
%
%   MSYS = MINREAL(SYS,TOL) further specifies the tolerance TOL
%   used for pole-zero cancellation or state dynamics elimination. 
%   The default value is TOL=SQRT(EPS) and increasing this tolerance
%   forces additional cancellations.
%
%   For a state-space model SYS=SS(A,B,C,D),
%      [MSYS,U] = MINREAL(SYS)
%   also returns an orthogonal matrix U such that (U*A*U',U*B,C*U') 
%   is a Kalman decomposition of (A,B,C). 
%
%   See also SS/SMINREAL, BALRED, BALREAL, LTI.

%   J.N. Little 7-17-86
%   Revised A.C.W.Grace 12-1-89
%   Rewritten P. Gahinet 4-20-98
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:36:45 $

% Note: no balancing since nearness to non-minimal is not
% invariant under ill-conditioned transf.
% Take for instance A = [1 100;1e-14 1], B = [1;0], C=[1 1]
ni = nargin;
no = nargout;
error(nargchk(1,3,ni))
if ni<2 || isempty(tol),
   tol = sqrt(eps);
end

% Validate data
if no>1 && numsys(sys)~=1
   ctrlMsgUtils.error('Control:transformation:minreal2','minreal')
elseif ~(isnumeric(tol) && isscalar(tol) && tol>0)
   ctrlMsgUtils.error('Control:transformation:minreal3')
end

% Eliminate cancelling dynamics
isStateSpace = isa(sys,'StateSpaceModel');
dispflag = isStateSpace && numsys(sys)==1 && (ni<3 || dispflag);
try
   hw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
   if isStateSpace && no>1
      [sys,u] = minreal_(sys,tol,dispflag);
   else
      sys = minreal_(sys,tol,dispflag); 
      u = [];
   end
catch E
   ltipack.throw(E,'command','minreal',class(sys))
end