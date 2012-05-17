%   SPARSE Create sparse matrix.  
%   S = SPARSE(X) converts a sparse or full matrix to sparse form by squeezing
%   out any zero elements.
%
%   S = sparse(i,j,s,m,n,nzmax) uses vectors i, j, and s to generate an m-by-n
%   sparse matrix such that S(i(k),j(k)) = s(k), with space allocated for nzmax
%   nonzeros. Vectors i, j, and s are all the same length. Any elements of s
%   that are zero are ignored, along with the corresponding values of i and
%   j. Any elements of s that have duplicate values of i and j are added
%   together.To simplify this six-argument call, you can pass scalars for the
%   argument s and one of the arguments i or j.in which case they are expanded
%   so that i, j, and s all have the same length.
%
%   The simplifications of the six-argument call are:
%
%   S = SPARSE(i,j,s,m,n) where nzmax = length(s).
%
%   S = SPARSE(i,j,s) where m = max(i) and n = max(j).
%
%   S = SPARSE(m,n) abbreviates SPARSE([],[],[],m,n,0).  This
%   generates the ultimate sparse matrix, an m-by-n all zero matrix.
%
%   The argument s and one of the arguments i or j may be scalars,
%   in which case they are expanded so that the first three arguments
%   all have the same length.
%
%   For example, this dissects and then reassembles a sparse matrix:
%
%              [i,j,s] = find(S);
%              [m,n] = size(S);
%              S = sparse(i,j,s,m,n);
%
%   So does this, if the last row and column have nonzero entries:
%
%              [i,j,s] = find(S);
%              S = sparse(i,j,s);
%
%   All of MATLAB's built-in arithmetic, logical and indexing operations
%   can be applied to sparse matrices, or to mixtures of sparse and
%   full matrices.  Operations on sparse matrices return sparse matrices
%   and operations on full matrices return full matrices.  In most cases,
%   operations on mixtures of sparse and full matrices return full
%   matrices.  The exceptions include situations where the result of
%   a mixed operation is structurally sparse, eg.  A .* S is at least
%   as sparse as S .  Some operations, such as S >= 0, generate
%   "Big Sparse", or "BS", matrices -- matrices with sparse storage
%   organization but few zero elements.
%
%   See also ISSPARSE, SPALLOC, SPONES, SPEYE, SPCONVERT, FULL, FIND, SPARFUN.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 5.11.4.7 $  $Date: 2010/03/31 18:24:45 $
%   Built-in function.
