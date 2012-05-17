%ERFINV Inverse error function.
%   X = ERFINV(Y) is the inverse error function for each element of Y.
%   The inverse error function satisfies y = erf(x), for -1 <= y <= 1
%   and -inf <= x <= inf.
%
%   Class support for input Y:
%      float: double, single
%
%   See also ERF, ERFC, ERFCX, ERFCINV.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 5.15.4.4 $  $Date: 2009/03/16 22:18:34 $

%   Based on an algorithm by Peter J. Acklam for computing the inverse
%   normal cumulative distribution function.  Uses a rational
%   approximation to the inverse error function, refined with a single
%   iteration of Halley's rational method.
