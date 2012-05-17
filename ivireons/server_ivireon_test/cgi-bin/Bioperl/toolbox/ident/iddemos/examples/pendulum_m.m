function [dx, y] = pendulum_m(t, x, u, g, l, b, m, varargin)
%PENDULUM_M  A pendulum system.

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:52:24 $

% Output equation.
y = x(1);                                   % Angular position.

% State equations.
dx = [x(2);                             ... % Angular position.
      -(g/l)*sin(x(1))-b/(m*l^2)*x(2)   ... % Angular velocity.
     ];