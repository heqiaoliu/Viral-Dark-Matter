%NZMAX  Amount of storage allocated for nonzero matrix elements.
%   For a sparse matrix, NZMAX(S) is the number of storage locations
%   allocated for the nonzero elements in S.
%
%   For a full matrix, NZMAX(S) is prod(size(S)).
%   In both cases, nnz(S) <= nzmax(S) <= prod(size(S)).
%
%   See also NNZ, NONZEROS, SPALLOC.

%   Copyright 1984-2006 The MathWorks, Inc. 
%   $Revision: 5.8.4.2 $  $Date: 2006/04/25 07:18:41 $
%   Built-in function.
