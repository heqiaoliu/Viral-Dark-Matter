function Y = dirac(X)
%DIRAC  Delta function.
%    DIRAC(X) is zero for all X, except X == 0 where it is infinite.
%    DIRAC(X) is not a function in the strict sense, but rather a
%    distribution with int(dirac(x-a)*f(x),-inf,inf) = f(a) and
%    diff(heaviside(x),x) = dirac(x).
%    See also HEAVISIDE.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/09 20:41:28 $

Y = zeros(size(X));
Y(X == 0) = Inf;
