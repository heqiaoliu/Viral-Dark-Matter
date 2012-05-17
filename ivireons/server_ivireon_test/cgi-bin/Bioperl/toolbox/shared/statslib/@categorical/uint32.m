function b = uint32(a)
%UINT32 Convert categorical array to an UINT32 array.
%   B = UINT32(A) converts the categorical array A to a UINT32 array.  Each
%   element of B contains the internal categorical level code for the
%   corresponding element of A.
%
%   Undefined elements of A are assigned the value 0 in B.
%
%   See also CATEGORICAL/DOUBLE, CATEGORICAL/INT32.

%   Copyright 2006-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2008/12/01 07:41:26 $

b = uint32(a.codes);
