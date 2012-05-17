function b = int16(a)
%INT16 Convert categorical array to an INT16 array.
%   B = INT16(A) converts the categorical array A to an INT16 array.  Each
%   element of B contains the internal categorical level code for the
%   corresponding element of A.
%
%   Undefined elements of A are assigned the value 0 in B.
%
%   See also CATEGORICAL/DOUBLE, CATEGORICAL/UINT16.

%   Copyright 2006-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2008/12/01 07:41:18 $

b = int16(a.codes);
