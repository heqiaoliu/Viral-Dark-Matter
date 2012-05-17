function b = double(a)
%DOUBLE Convert categorical array to DOUBLE array.
%   B = DOUBLE(A) converts the categorical array A to a DOUBLE array.  Each
%   element of B contains the internal categorical level code for the
%   corresponding element of A.
%
%   Undefined elements of A are assigned the value NaN in B.
%
%   See also CATEGORICAL/SINGLE.

%   Copyright 2006-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2008/12/01 07:41:16 $

b = double(a.codes);
b(b==0) = NaN;