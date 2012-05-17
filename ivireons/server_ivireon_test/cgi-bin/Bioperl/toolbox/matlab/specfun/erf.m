%ERF Error function.
%   Y = ERF(X) is the error function for each element of X.  X must be
%   real. The error function is defined as:
%
%     erf(x) = 2/sqrt(pi) * integral from 0 to x of exp(-t^2) dt.
%
%   Class support for input X:
%      float: double, single
%
%   See also ERFC, ERFCX, ERFINV, ERFCINV.

%   Reference:
%   [1] Abramowitz & Stegun, Handbook of Mathematical Functions, sec. 7.1.
%   [2] W. J. Cody, Rational Chebyshev Approximations for the Error
%       Function, Math. Comp., pp. 631-638, 1969

%   Copyright 1984-2009 The MathWorks, Inc. 
%   $Revision: 5.13.4.6 $  $Date: 2009/11/16 22:27:15 $
