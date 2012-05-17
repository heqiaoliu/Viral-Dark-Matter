function b = circshift(a,shiftsize)
%CIRCSHIFT Shift categorical array circularly.
%   B = CIRCSHIFT(A,SHIFTSIZE) circularly shifts the values in the categorical
%   array A by SHIFTSIZE elements. SHIFTSIZE is a vector of integer scalars
%   where the N-th element specifies the shift amount for the N-th dimension
%   of array A. If an element in SHIFTSIZE is positive, the values of A are
%   shifted down (or to the right). If it is negative, the values of A are
%   shifted up (or to the left).
%
%   See also CATEGORICAL/PERMUTE, CATEGORICAL/SHIFTDIM.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:36:41 $

b = a;
b.codes = circshift(a.codes,shiftsize);
