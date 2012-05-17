function [dx, y] = robot_m(t, x, u, g, Fc, r, Im, m, pl, L, com, Ia1, Ia, varargin)
%ROBOT_M  A simplified Manutec r3 robot with three arms.

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:29:06 $

% Output equations.
y = [x(1);                ... % Relative angle between fundament and arm 1.
     x(2);                ... % Relative angle between arm 1 and arm 2.
     x(3)                 ... % Relative angle between arm 2 and arm 3.
    ];

% Intermediate variables.
% A. Components of the symmetric and positive definite mass matrix M(x, p), a 3x3 matrix.
M = zeros(3, 3);
M(1, 1) = Ia1 + r(1)^2*Im(1) + com(1,2)^2*m(2) + com(1,1)^2*m(1) + Ia(3,1)*cos(x(2))^2    ...
        + (Ia(2,1) + com(2,1)^2*m(1))*sin(x(2))^2 + Ia(3,2)*cos(x(2)+x(3))^2              ...
        + Ia(2,2)*sin(x(2)+x(3))^2 + pl*(L(1)*sin(x(2)) + L(2)*sin(x(2)+x(3)))^2          ...
        + m(2)*(L(1)*sin(x(2)) + com(2,2)*sin(x(2)+x(3)))^2;
M(1, 3) = (Ia(4,2) - com(1,2)*com(2,2)*m(2))*cos(x(2)+x(3));
M(1, 2) = (Ia(4,1) - com(1,2)*L(1)*m(2) - com(1,1)*com(2,1)*m(1))*cos(x(2)) + M(1, 3);
M(2, 2) = Ia(1,2) + Ia(1,1) + r(2)^2*Im(2) + com(2,1)^2*m(1) + (com(2,2)^2 + L(1)^2)*m(2) ...
        + (L(2)^2 + L(1)^2)*pl + 2*L(1)*(com(2,2)*m(2) + L(2)*pl)*cos(x(3));
M(2, 3) = Ia(1,2) + r(3)*Im(3) + com(2,2)^2*m(2) + L(2)^2*pl                              ...
        + L(1)*(com(2,2)*m(2) + L(2)*pl)*cos(x(3));
M(3, 3) = Ia(1,2) + r(3)^2*Im(3) + com(2,2)^2*m(2) + L(2)^2*pl;
M(2, 1) = M(1, 2);
M(3, 1) = M(1, 3);
M(3, 2) = M(2, 3);

% B. Inputs.
F = [Fc(1)*u(1); Fc(2)*u(2); Fc(3)*u(3)];

% C. Gravitational forces G.
G = zeros(3, 1);
G(2) = g*(com(2,1)*m(1) + L(1)*(m(2) + pl))*sin(x(2)) ...
     + g*(com(2,2)*m(2) + L(2)*pl)*sin(x(2)+x(3));
G(3) = g*(com(2,2)*m(2) + L(2)*pl)*sin(x(2)+x(3));

% D. Coriolis and centrifugal force components Gamma and forces H.
Gamma = zeros(5, 1);
Gamma(2) = (Ia(3,2) - Ia(2,2) - com(2,2)^2*m(2) - L(2)^2*pl)*sin(x(2)+x(3))*cos(x(2)+x(3))     ...
         - L(1)*(com(2,2)*m(2) + L(2)*pl)*sin(x(2))*cos(x(2)+x(3));
Gamma(1) = (Ia(3,1) - Ia(2,1) - com(2,1)^2*m(1) - L(1)^2*(m(2)+pl))*cos(x(2))*sin(x(2))        ...
         - L(1)*(com(2,2)*m(2) + L(2)*pl)*sin(x(2))*cos(x(2)+x(3)) + Gamma(2);
Gamma(4) = (Ia(4,2) - com(1,2)*com(2,2)*m(2))*sin(x(2)+x(3));
Gamma(3) = (Ia(4,1) - com(1,2)*L(1)*m(2) - com(1,1)*com(2,1)*m(1))*sin(x(2)) + Gamma(4);
Gamma(5) = L(1)*(com(2,2)*m(2) + L(2)*pl);
H = [2*x(1)*(Gamma(1)*x(2) + Gamma(2)*x(3)) + Gamma(3)*x(2)^2 + Gamma(4)*(2*x(2) + x(3))*x(3); ...
     -Gamma(1)*x(1)^2 + Gamma(5)*(2*x(2) + x(3))*x(3);                                         ...
     -Gamma(2)*x(1)^2 - Gamma(5)*x(2)^2];

% State equations.
dx = [x(4); x(5); x(6); pinv(M)*(F + G + H)];