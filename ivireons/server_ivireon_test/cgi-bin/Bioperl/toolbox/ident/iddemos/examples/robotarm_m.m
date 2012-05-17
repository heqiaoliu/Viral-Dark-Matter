function [dx, y] = robotarm_m(t, x, u, Fv, Fc, Fcs, alpha, beta, J, am, ...
                              ag, kg1, kg3, dg, ka, da, varargin)
%ROBOTARM_M  A physically parameterized robot arm.

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:29:08 $

% Output equation.
y = x(3);                                                   % Rotational velocity of the motor.

% Intermediate quantities (gear box).
tauf = Fv*x(3)+(Fc+Fcs/cosh(alpha*x(3)))*tanh(beta*x(3));   % Gear friction torque.
taus = kg1*x(1)+kg3*x(1)^3;                                 % Spring torque.

% State equations.
dx = [x(3)-x(4);       ... % Rotational velocity difference between the motor and the gear-box.
      x(4)-x(5);       ... % Rotational velocity difference between the gear-box and the arm.
      1/(J*am)*(-taus-dg*(x(3)-x(4))-tauf+u);                ... % Rotational velocity of the motor.
      1/(J*ag)*(taus+dg*(x(3)-x(4))-ka*x(2)-da*(x(4)-x(5))); ... % Rotational velocity after the gear-box.
      1/(J*(1-am-ag))*(ka*x(2)+da*(x(4)-x(5)))               ... % Rotational velocity of the robot arm.
     ];