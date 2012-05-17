function b = transpose(a)
%TRANSPOSE Transpose a categorical matrix.
%   B = TRANSPOSE(A) returns the transpose of the 2-dimensional categorical
%   matrix A.  Note that CTRANSPOSE is identical to TRANSPOSE for categorical
%   arrays.
%
%   TRANSPOSE is called for the syntax A.'.
%
%   See also CATEGORICAL/CTRANSPOSE, CATEGORICAL/PERMUTE.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:37:29 $

b.codes = a.codes.';
