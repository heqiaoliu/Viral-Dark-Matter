function y = qfunc(x)
%QFUNC  Q function.
%   Y = QFUNC(X) returns 1 minus the cumulative distribution function of the 
%   standardized normal random variable for each element of X.  X must be a real
%   array. The Q function is defined as:
%
%     Q(x) = 1/sqrt(2*pi) * integral from x to inf of exp(-t^2/2) dt
%
%   It is related to the complementary error function (erfc) according to
%
%     Q(x) = 0.5 * erfc(x/sqrt(2))
%
%   See also QFUNCINV, ERF, ERFC, ERFCX, ERFINV, ERFCINV.

%   Copyright 1996-2007 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2007/08/03 21:17:55 $

if (~isreal(x) || ischar(x))
  error('comm:qfunc:InvalidArg','The argument of the Q function must be a real array.'); 
end
y = 0.5 * erfc(x/sqrt(2));
return;