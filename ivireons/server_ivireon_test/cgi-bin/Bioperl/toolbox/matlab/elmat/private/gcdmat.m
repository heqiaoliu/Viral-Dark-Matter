function A = gcdmat(n,classname)
%GCDMAT  GCD matrix.
%   A = GALLERY('GCDMAT',N) is the N-by-N matrix with (i,j) entry
%   GCD(i,j).  A is symmetric positive definite, and A.^r is
%   symmetric positive semidefinite for all nonnegative r.

%   Reference:
%   R. Bhatia, Infinitely divisible matrices, Amer. Math. Monthly,
%   (2005), to appear.
%
%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/11/18 14:14:56 $

a = cast(1:n,classname);
A = a(ones(n,1),:);
A = gcd(A,A');
