function b = int32(a)
%INT32 Convert categorical array to an INT32 array.
%   B = INT32(A) converts the categorical array A to an INT32 array.  Each
%   element of B contains the internal categorical level code for the
%   corresponding element of A.
%
%   Undefined elements of A are assigned the value 0 in B.
%
%   See also CATEGORICAL/DOUBLE, CATEGORICAL/UINT32.

%   Copyright 2006-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2008/12/01 07:41:19 $

b = int32(a.codes);
