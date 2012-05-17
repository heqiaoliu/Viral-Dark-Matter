function b = permute(a,order)
%PERMUTE Permute dimensions of a categorical array.
%   B = PERMUTE(A,ORDER) rearranges the dimensions of the categorical array A
%   so that they are in the order specified by the vector ORDER.  The array
%   produced has the same values as A but the order of the subscripts needed
%   to access any particular element are rearranged as specified by ORDER. The
%   elements of ORDER must be a rearrangement of the numbers from 1 to N.
%
%   See also CATEGORICAL/IPERMUTE, CATEGORICAL/CIRCSHIFT.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:37:13 $

b = a;
b.codes = permute(a.codes,order);
