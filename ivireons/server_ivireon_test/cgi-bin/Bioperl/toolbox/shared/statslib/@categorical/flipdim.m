function b = flipdim(a,dim)
%FLIPDIM Flip categorical array along specified dimension.
%   B = FLIPDIM(A,DIM) returns the categorical array A with dimension DIM flipped.
%
%   See also CATEGORICAL/FLIPLR,  CATEGORICAL/FLIPUD, CATEGORICAL/ROT90, CATEGORICAL/PERMUTE.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:36:49 $

b = a;
b.codes = flipdim(a.codes,dim);
