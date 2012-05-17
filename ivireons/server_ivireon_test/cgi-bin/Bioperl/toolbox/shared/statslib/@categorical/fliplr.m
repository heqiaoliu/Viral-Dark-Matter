function b = fliplr(a)
%FLIPLR Flip categorical matrix in left/right direction.
%   B = FLIPLR(A) returns the 2-dimensional categorical matrix A with rows
%   preserved and columns flipped in the left/right direction.
%
%   See also CATEGORICAL/FLIPDIM,  CATEGORICAL/FLIPUD, CATEGORICAL/ROT90.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:36:50 $

b = a;
b.codes = fliplr(a.codes);
