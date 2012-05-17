function [c,ceq] = expensive_confun(x)
%EXPENSIVE_CONFUN An expensive constraint function used in optimparfor demo.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 21:51:03 $

% Simulate an expensive function by performing an expensive computation
eig(magic(450));
% Evaluate constraints
c = [1.5 + x(1)*x(2)*x(3) - x(1) - x(2) - x(4); 
     -x(1)*x(2) + x(4) - 10];
% No nonlinear equality constraints:
ceq = [];
