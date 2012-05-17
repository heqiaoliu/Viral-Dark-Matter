function [dx, y] = twobodies_m(t, x, u, m, k, e, f, varargin)
%TWOBODIES_M  One body moving against another.

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:29:12 $

% Output equation.
y = x(1);                              % Position.

% State equations.
dx = [x(2);                        ... % Position.
      (u(1)-k*x(2)-x(3))/m;        ... % Velocity.
      (-abs(x(2))*x(3)+e*x(2))/f   ... % Dry friction force.
     ];