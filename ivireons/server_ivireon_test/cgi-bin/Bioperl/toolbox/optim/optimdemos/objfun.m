function f = objfun(x)
%OBJFUN Objective function.
% Documentation example.

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/02/29 12:47:47 $

f = exp(x(1)) * (4*x(1)^2 + 2*x(2)^2 + 4*x(1)*x(2) + 2*x(2) + 1);
