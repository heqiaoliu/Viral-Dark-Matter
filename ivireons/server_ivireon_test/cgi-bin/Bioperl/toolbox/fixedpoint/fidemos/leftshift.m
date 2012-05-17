function y = leftshift(x, n)
%LEFTSHIFT  Arithmetic left-shift.
%    Y = LEFTSHIFT(X, N) returns the value of fixed-point data X
%    arithmetic-left-shifted by N bits.  If X is not fixed-point, then
%    it returns X*2^N.

%   Thomas A. Bryan
%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $
if isfi(x)
  y = bitshift(x, n);
else
  y = x * 2.^(n);
end
