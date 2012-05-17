function p = colperm(S)
%COLPERM Column permutation.
%   p = COLPERM(S) returns a permutation vector that reorders the
%   columns of the sparse matrix S in nondecreasing order of nonzero
%   count.  This is sometimes useful as a preordering for LU
%   factorization: lu(S(:,p)).
%
%   If S is symmetric, then COLPERM generates a permutation so that
%   both the rows and columns of S(p,p) are ordered in nondecreasing
%   order of nonzero count.  If S is positive definite, this is
%   sometimes useful as a preordering for Cholesky factorization:
%   chol(S(p,p)).
%
%   COLPERM is not the best ordering in the world, but it's fast to
%   compute, and it does a pretty good job.
%
%   See also COLAMD, SYMAMD, SYMRCM.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 5.11.4.3 $  $Date: 2009/04/21 03:26:09 $

if size(S,1) <= 1
    [~,p] = sort(full(spones(S)));
else
    [~,p] = sort(full(sum(spones(S))));
end
