function [dx, y] = vehicle_m(t, x, u, m, a, b, Cx, Cy, CA, varargin)
%VEHICLE_M  A biycle vehicle model structure commonly employed in the
%   vehicle dynamics literature.

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:29:16 $

% Output equations.
y = [x(1);                                                ... % Longitudinal vehicle velocity.
     1/m*(  Cx*(u(1)+u(2))*sin(u(5))                      ... % Lateral vehicle acceleration.
             + 2*Cy*(u(5)-(x(2)+a*x(3))/x(1))*cos(u(5))   ...
             + 2*Cy*(b*x(3)-x(2))/x(1));                  ...
     x(3)];                                               ... % Yaw rate.

% State equations.
dx = [x(2)*x(3)+1/m*(  Cx*(u(1)+u(2))*cos(u(5))                       ... % Longitudinal vehicle velocity.
                        - 2*Cy*(u(5)-(x(2)+a*x(3))/x(1))*sin(u(5))    ...
                        + Cx*(u(3)+u(4))-CA*x(1)^2);                  ...
      -x(1)*x(3)+1/m*(  Cx*(u(1)+u(2))*sin(u(5))                      ... % Lateral vehicle velocity.
                         + 2*Cy*(u(5)-(x(2)+a*x(3))/x(1))*cos(u(5))   ...
                         + 2*Cy*(b*x(3)-x(2))/x(1));                  ...
      1/((0.5*(a+b))^2*m)*(  a*(  Cx*(u(1)+u(2))*sin(u(5))            ... % Yaw rate.
                                + 2*Cy*(u(5)-(x(2)+a*x(3))/x(1))*cos(u(5))) ...
                           - 2*b*Cy*(b*x(3)-x(2))/x(1))];