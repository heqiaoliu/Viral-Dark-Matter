function b = ctranspose(a)
%CTRANSPOSE Transpose a categorical matrix.
%   B = CTRANSPOSE(A) returns the transpose of the 2-dimensional categorical
%   matrix A.  Note that CTRANSPOSE is identical to TRANSPOSE for categorical
%   arrays.
%
%   CTRANSPOSE is called for the syntax A'.
%
%   See also CATEGORICAL/TRANSPOSE, CATEGORICAL/PERMUTE.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:36:42 $

b = a;
b.codes = a.codes';
