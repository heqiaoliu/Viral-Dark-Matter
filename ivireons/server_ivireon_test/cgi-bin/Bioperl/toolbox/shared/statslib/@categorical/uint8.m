function b = uint8(a)
%UINT8 Convert categorical array to a UINT8 array.
%   B = UINT8(A) converts the categorical array A to a UINT8 array.  Each
%   element of B contains the internal categorical level code for the
%   corresponding element of A.
%
%   Undefined elements of A are assigned the value 0 in B.  If A contains
%   more than INTMAX('uint8') levels, the internal codes will saturate to
%   INTMAX('uint8') when cast to UINT8.
%
%   See also CATEGORICAL/DOUBLE, CATEGORICAL/INT8.

%   Copyright 2006-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2008/12/01 07:41:28 $

b = uint8(a.codes);
