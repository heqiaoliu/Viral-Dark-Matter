function [boo,p] = isNilpotent(a)
%ISNILPONENT  Checks if matrix is structurally nilpotent.
%
%   ISNILPONENT(A) returns true if the logical matrix A is structurally 
%   nilpotent (strictly upper triangular up to a permutation).
%
%   [TF,P] = ISNILPONENT(A) also returns the permutation P such that
%   B defined by B(P,P)=A is strictly upper triangular when TF is true.

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:19 $
n = size(a,1);
boo = true;
p = zeros(n,1);
% NZ counts number of nonzero entries in columns of active submatrix of A
nz = sum(a,1);
for ct=1:n
   % Column with smallest number of nonzero entries moves first
   % Note: nzmin should be zero for A to be strictly upper triangular
   [nzmin,jmin] = min(nz);
   boo = boo && (nzmin==0);
   p(jmin) = ct;
   % Update NZ by subtracting nonzero entries in permuted row
   nz = nz - double(a(jmin,:));
   nz(jmin) = NaN;  % mark column as visited
end
