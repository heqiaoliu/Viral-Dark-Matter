function b = flipud(a)
%FLIPUD Flip categorical matrix in up/down direction.
%   B = FLIPUD(A) returns the 2-dimensional categorical matrix A with columns
%   preserved and rows flipped in the up/down direction.
%
%   See also CATEGORICAL/FLIPDIM,  CATEGORICAL/FLIPUD, CATEGORICAL/ROT90.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:36:51 $

b = a;
b.codes = flipud(a.codes);
