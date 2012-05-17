function b = squeeze(a)
%SQUEEZE Squeeze singleton dimensions from a categorical array.
%   B = SQUEEZE(A) returns an array B with the same elements as the
%   categorical array A but with all the singleton dimensions removed.  A
%   singleton is a dimension such that size(A,DIM)==1.  2-D arrays are
%   unaffected by SQUEEZE so that row vectors remain rows.
%
%   See also CATEGORICAL/SHIFTDIM.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:37:24 $

b = a;
b.codes = squeeze(a.codes);
