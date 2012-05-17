function [c, v] = condest(A,t)
%CONDEST 1-norm condition number estimate.
%   C = CONDEST(A) computes a lower bound C for the 1-norm condition
%   number of a square matrix A.
%
%   C = CONDEST(A,T) changes T, a positive integer parameter equal to
%   the number of columns in an underlying iteration matrix.  Increasing the
%   number of columns usually gives a better condition estimate but increases
%   the cost.  The default is T = 2, which almost always gives an estimate
%   correct to within a factor 2.
%
%   [C,V] = CONDEST(A) also computes a vector V which is an approximate null
%   vector if C is large.  V satisfies NORM(A*V,1) = NORM(A,1)*NORM(V,1)/C.
%
%   Note: CONDEST invokes RAND.  If repeatable results are required,  then
%   see RAND for details on how to set the default stream state.
%
%   CONDEST is based on the 1-norm condition estimator of Hager [1] and a
%   block oriented generalization of Hager's estimator given by Higham and
%   Tisseur [2].  The heart of the algorithm involves an iterative search
%   to estimate ||A^{-1}||_1 without computing A^{-1}. This is posed as the
%   convex, but nondifferentiable, optimization problem: 
%
%         max ||A^{-1}x||_1 subject to ||x||_1 = 1. 
%
%   See also NORMEST1, COND, NORM, RAND.

%   Reference:
%   [1] William W. Hager, Condition estimates, 
%       SIAM J. Sci. Stat. Comput. 5, 1984, 311-316, 1984.
% 
%   [2] Nicholas J. Higham and Fran\c{c}oise Tisseur, 
%       A Block Algorithm for Matrix 1-Norm Estimation 
%       with an Application to 1-Norm Pseudospectra, 
%       SIAM J. Matrix Anal. App. 21, 1185-1201, 2000. 
%
%   Nicholas J. Higham
%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 5.18.4.4 $  $Date: 2010/02/25 08:09:59 $

if size(A,1) ~= size(A,2)
   error('MATLAB:condest:NonSquareMatrix', 'Matrix must be square.')
end
if isempty(A), c = 0; v = []; return, end
if nargin < 2, t = []; end

if issparse(A)
   [L,U,~,~] = lu(A,'vector');
else
   [L,U,~] = lu(A,'vector');
end
k = find(abs(diag(U))==0);
if ~isempty(k)
   c = Inf;
   n = length(A);
   v = zeros(n,1);
   k = min(k);
   v(k) = 1;
   if k > 1
      v(1:k-1) = -U(1:k-1,1:k-1)\U(1:k-1,k);
   end
else
   warns = warning('query','all');
   temp = onCleanup(@()warning(warns));
   warning('off','all');   
   [Ainv_norm, ~, v] = normest1(@condestf,t);
   A_norm = norm(A,1);
   c = Ainv_norm*A_norm;
end
v = v/norm(v,1);

    function f = condestf(flag, X)
        %CONDESTF   Function used by CONDEST.        
        if isequal(flag,'dim')
            f = max(size(L));
        elseif isequal(flag,'real')
            f = isreal(L) && isreal(U);
        elseif isequal(flag,'notransp')
            f = U\(L\X);
        elseif isequal(flag,'transp')
            f = L'\(U'\X);
        end
    end

end

