%ERFC Complementary error function.
%   Y = ERFC(X) is the complementary error function for each element
%   of X.  X must be real.  The complementary error function is
%   defined as:
%
%     erfc(x) = 2/sqrt(pi) * integral from x to inf of exp(-t^2) dt.
%             = 1 - erf(x).
%
%   Class support for input X:
%      float: double, single
%
%   See also ERF, ERFCX, ERFINV, ERFCINV.

%   Reference:
%   [1] Abramowitz & Stegun, Handbook of Mathematical Functions, sec. 7.1.
%   [2] W. J. Cody, Rational Chebyshev Approximations for the Error
%       Function, Math. Comp., pp. 631-638, 1969

%   Copyright 1984-2009 The MathWorks, Inc. 
%   $Revision: 5.12.4.6 $  $Date: 2009/11/16 22:27:16 $
