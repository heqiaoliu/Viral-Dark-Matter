function [dx, y] = aero_m(t, x, u, F, M, C, d, A, I, m, K, varargin)
%AERO_M  A non-linear aerodynamic system.

%   Copyright 2005-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2010/03/22 03:48:38 $

% Output equations.
y = [x(1);                              ... % Angular velocity around x-axis.
     x(2);                              ... % Angular velocity around y-axis.
     x(3);                              ... % Angular velocity around z-axis.
     -A*u(4)*(F(1)*x(5)+F(2)*u(3))/m;   ... % Acceleration in y-direction.
     -A*u(4)*(F(3)*x(4)+F(4)*u(2))/m    ... % Acceleration in z-direction.
    ];

% State equations.
dx = [1/I(1)*(d*A*(M(1)*x(5)+0.5*M(2)*d*x(1)/u(5)+       ... % Angular velocity around x-axis.
           M(3)*u(1))*u(4)-(I(3)-I(2))*x(2)*x(3))+       ...
           K*(u(6)-x(1));                                ...
        1/I(2)*(d*A*(M(4)*x(4)+0.5*M(5)*d*x(2)/u(5)+     ... % Angular velocity around y-axis.
           M(6)*u(2))*u(4)-(I(1)-I(3))*x(1)*x(3))+       ...
           K*(u(7)-x(2));                                ...
        1/I(3)*(d*A*(M(7)*x(5)+M(8)*x(4)*x(5)+           ... % Angular velocity around z-axis.
           0.5*M(9)*d*x(3)/u(5)+M(10)*u(1)+              ...
           M(11)*u(3))*u(4)-(I(2)-I(1))*x(1)*x(2))+      ...
           K*(u(8)-x(3));                                ...
        (-A*u(4)*(F(3)*x(4)+F(4)*u(2)))/(m*u(5))-        ... % Angle of attack.
           x(1)*x(5)+x(2)+K*(u(9)/u(5)-x(4))+C*x(5)^2;   ...
        (-A*u(4)*(F(1)*x(5)+F(2)*u(3)))/(m*u(5))-        ... % Angle of sideslip.
           x(3)+x(1)*x(4)+K*(u(10)/u(5)-x(5))            ...
       ];