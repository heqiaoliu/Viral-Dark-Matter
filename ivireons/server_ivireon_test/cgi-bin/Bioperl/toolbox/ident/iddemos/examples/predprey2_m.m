function [dx, y] = predprey2_m(t, x, u, p1, p2, p3, p4, p5, varargin)
%PREDPREY2_M  A predator-prey system with prey crowding.

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:29:02 $

% Output equations.
y = [x(1);                             ... % Predator species.
     x(2)                              ... % Prey species.
    ];

% State equations.
dx = [p1*x(1)+p2*x(2)*x(1);            ... % Predator species.
      p3*x(2)-p4*x(1)*x(2)-p5*x(2)^2   ... % Prey species.
     ];