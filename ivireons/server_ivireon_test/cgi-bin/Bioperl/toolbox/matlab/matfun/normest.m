function [e,cnt] = normest(S,tol)
%NORMEST Estimate the matrix 2-norm.
%   NORMEST(S) is an estimate of the 2-norm of the matrix S.
%   NORMEST(S,tol) uses relative error tol instead of 1.e-6.
%   [nrm,cnt] = NORMEST(..) also gives the number of iterations used.
%
%   This function is intended primarily for sparse matrices,
%   although it works correctly and may be useful for large, full
%   matrices as well.  Use NORMEST when your problem is large
%   enough that NORM takes too long to compute and an approximate
%   norm is acceptable.
%
%   Class support for input S:
%      float: double, single
%
%   See also NORM, COND, RCOND, CONDEST.

%   Copyright 1984-2008 The MathWorks, Inc. 
%   $Revision: 5.14.4.6 $  $Date: 2008/06/20 08:00:46 $

if nargin < 2, tol = 1.e-6; end
maxiter = 100; % should never take this many iterations. 
x = sum(abs(S),1)';
cnt = 0;
e = norm(x);
if e == 0, return, end
x = x/e;
e0 = 0;
while abs(e-e0) > tol*e
   e0 = e;
   Sx = S*x;
   if nnz(Sx) == 0
      Sx = rand(size(Sx));
   end
   x = S'*Sx;
   normx = norm(x);
   e = normx/norm(Sx);
   x = x/normx;
   cnt = cnt+1;
   if cnt > maxiter
      warning('MATLAB:normest:notconverge', '%s%d%s%g', ...
              'NORMEST did not converge for ', maxiter, ' iterations with tolerance ', tol);
      break;
   end
end
