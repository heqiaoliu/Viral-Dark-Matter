function [c, ceq, dc, dceq] = confungrad(x)
%CONFUNGRAD Nonlinear inequality constraints and their gradients.
% Documentation example.

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/02/29 12:47:43 $

c = [1.5 + x(1)*x(2) - x(1) - x(2); 
     -x(1)*x(2) - 10];
% Gradient (partial derivatives) of nonlinear inequality constraints:
dc = [x(2)-1, -x(2); 
      x(1)-1, -x(1)];
% no nonlinear equality constraints (and gradients)
ceq = [];
dceq = [];