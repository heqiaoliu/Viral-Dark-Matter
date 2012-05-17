function b = uint16(a)
%UINT16 Convert categorical array to an UINT16 array.
%   B = UINT16(A) converts the categorical array A to a UINT16 array.  Each
%   element of B contains the internal categorical level code for the
%   corresponding element of A.
%
%   Undefined elements of A are assigned the value 0 in B.
%
%   See also CATEGORICAL/DOUBLE, CATEGORICAL/INT16.

%   Copyright 2006-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2008/12/01 07:41:25 $

b = uint16(a.codes);
