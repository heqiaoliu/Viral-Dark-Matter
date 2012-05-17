function c = levelcounts(a,dim)
%LEVELCOUNTS Counts of elements for a categorical array's levels.
%   C = LEVELCOUNTS(A), for a categorical vector A, counts the number of
%   elements in A equal to each of A's possible levels.  The vector C contains
%   those counts, and has as many elements as A has levels.
%
%   For matrices, LEVELCOUNTS(A) is a matrix of column counts.  For N-D
%   arrays, LEVELCOUNTS(A) operates along the first non-singleton dimension.
%  
%   C = LEVELCOUNTS(A,DIM) operates along the dimension DIM.
%
%   See also CATEGORICAL/ISLEVEL, CATEGORICAL/ISMEMBER, CATEGORICAL/SUMMARY.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:37:08 $
if nargin < 2
    c = histc(a.codes,1:length(a.labels));
else
    c = histc(a.codes,1:length(a.labels),dim);
end

