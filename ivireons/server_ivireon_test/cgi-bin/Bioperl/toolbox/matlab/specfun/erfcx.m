%ERFCX Scaled complementary error function.
%   Y = ERFCX(X) is the scaled complementary error function for each
%   element of X.  X must be real.  The scaled complementary error
%   function is defined as: 
%
%     erfcx(x) = exp(x^2) * erfc(x)
%
%   which is approximately (1/sqrt(pi)) * 1/x for large x.
%
%   Class support for input X:
%      float: double, single
%
%   See also ERF, ERFC, ERFINV, ERFCINV.

%   Reference:
%   [1] Abramowitz & Stegun, Handbook of Mathematical Functions, sec. 7.1.
%   [2] W. J. Cody, Rational Chebyshev Approximations for the Error
%       Function, Math. Comp., pp. 631-638, 1969

%   Copyright 1984-2009 The MathWorks, Inc. 
%   $Revision: 5.10.4.6 $  $Date: 2009/11/16 22:27:17 $
