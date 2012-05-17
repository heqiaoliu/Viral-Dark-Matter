function y = isfi(A)
%isfi(A) returns 1 if A is a FI object, and 0 otherwise.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/04/21 21:49:48 $

y = isa(A, 'embedded.fi');
