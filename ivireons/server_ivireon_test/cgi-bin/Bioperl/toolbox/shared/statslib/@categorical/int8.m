function b = int8(a)
%INT8 Convert categorical array to an INT8 array.
%   B = INT8(A) converts the categorical array A to an INT8 array.  Each
%   element of B contains the internal categorical level code for the
%   corresponding element of A.
%
%   Undefined elements of A are assigned the value 0 in B.  If A contains
%   more than INTMAX('int8') levels, the internal codes will saturate to
%   INTMAX('int8') when cast to INT8.
%
%   See also CATEGORICAL/DOUBLE, CATEGORICAL/UINT8.

%   Copyright 2006-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2008/12/01 07:41:21 $

b = int8(a.codes);
