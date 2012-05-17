function b = uint64(a)
%UINT64 Convert categorical array to a UINT64 array.
%   B = UINT64(A) converts the categorical array A to a UINT64 array.  Each
%   element of B contains the internal categorical level code for the
%   corresponding element of A.
%
%   Undefined elements of A are assigned the value 0 in B.
%
%   See also CATEGORICAL/DOUBLE, CATEGORICAL/INT64.

%   Copyright 2006-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2008/12/01 07:41:27 $

b = uint64(a.codes);
