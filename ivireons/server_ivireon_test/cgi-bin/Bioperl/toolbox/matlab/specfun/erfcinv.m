%ERFCINV Inverse complementary error function.
%   X = ERFCINV(Y) is the inverse of the complementary error function
%   for each element of Y.  It satisfies y = erfc(x) for 2 >= y >= 0 and
%   -Inf <= x <= Inf.
%
%   Class support for input Y:
%      float: double, single
%
%   See also ERF, ERFC, ERFCX, ERFINV.

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.4.4.4 $  $Date: 2009/03/16 22:18:32 $

%   Based on an algorithm by Peter J. Acklam for computing the inverse
%   normal cumulative distribution function.  Uses a rational
%   approximation to the inverse complementary error function, refined
%   with a single iteration of Halley's rational method.
