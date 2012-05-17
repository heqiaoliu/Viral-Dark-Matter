function [X,p] = lurectpiv(A)
%LURECTPIV  LU factorization of rectangular matrix with pivot vector.
%   [X,p] = LURECTPIV(A) for m-by-n A with m >= n produces a unit
%   lower trapezoidal matrix L the same size as A, a square upper
%   triangular matrix U, and a permutation vector p, so that L*U = A(p,:)

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/06/11 17:09:33 $

[m,n] = size(A);
if isempty(A)
   X = A;
   p = (1:m);
elseif issparse(A)
   [L,U,P] = lu(A);
   X = L - speye(m,n);
   X(1:n,:) = X(1:n,:) + U;
   [q,ans] = find(P);
   p(q) = (1:m);
else
   [X,p] = dgetrf(A);
end
