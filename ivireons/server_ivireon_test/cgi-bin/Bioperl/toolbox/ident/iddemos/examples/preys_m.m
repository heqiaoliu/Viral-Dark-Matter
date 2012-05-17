function [dx, y] = preys_m(t, x, u, p1, p2, p3, p4, varargin)
%PREYS_M  Two species that compete for the same food.

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:29:04 $

% Output equations.
y = [x(1);                           ... % Prey species 1.
     x(2)                            ... % Prey species 2.
    ];

% State equations.
dx = [p1*x(1)-p2*(x(1)+x(2))*x(1);   ... % Prey species 1.
      p3*x(2)-p4*(x(1)+x(2))*x(2)    ... % Prey species 2.
     ];