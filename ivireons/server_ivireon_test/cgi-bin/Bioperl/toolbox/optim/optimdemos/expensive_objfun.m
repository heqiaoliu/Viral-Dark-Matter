function f = expensive_objfun(x)
%EXPENSIVE_OBJFUN An expensive objective function used in optimparfor demo.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 21:51:04 $

% Simulate an expensive function by performing an expensive computation
eig(magic(300));
% Evaluate objective function
f = exp(x(1)) * (4*x(3)^2 + 2*x(4)^2 + 4*x(1)*x(2) + 2*x(2) + 1);
