function [f, G] = objfungrad(x)
%OBJFUNGRAD Objective function and its gradients.
% Documentation example.

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/02/29 12:47:48 $

f =exp(x(1)) * (4*x(1)^2 + 2*x(2)^2 + 4*x(1)*x(2) + 2*x(2) + 1);
% gradient (partial derivatives) of the objective function:
t = exp(x(1))*(4*x(1)^2+2*x(2)^2+4*x(1)*x(2)+2*x(2)+1);
G = [ t + exp(x(1)) * (8*x(1) + 4*x(2)) ...
      exp(x(1))*(4*x(1)+4*x(2)+2)];
