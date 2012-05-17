function [dx, y] = narendrali_m(t, x, u, p, varargin)
%NARENDRALI_M  A discrete-time Narendra-Li benchmark system.

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:28:56 $

% Output equation.
y = x(1)/(1+p(4)*sin(x(2)))+x(2)/(1+p(5)*sin(x(1)));

% State equations.
dx = [(x(1)/(1+x(1)^2)+p(1))*sin(x(2));              ... % State 1.
      x(2)*cos(x(2))+x(1)*exp(-(x(1)^2+x(2)^2)/p(2)) ... % State 2.
         + u(1)^3/(1+u(1)^2+p(3)*cos(x(1)+x(2)))     ...
     ];