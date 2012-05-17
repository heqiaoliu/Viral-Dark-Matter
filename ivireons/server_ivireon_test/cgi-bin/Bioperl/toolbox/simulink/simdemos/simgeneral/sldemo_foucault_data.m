%SLDEMO_FOUCAULT_DATA
%
% Contains initialization data for the foucault pendulum model
%
% See also: SLDEMO_FOUCAULT, SLDEMO_FOUCAULT, SLDEMO_FOUCAULT_ANIMATE

%   Copyright 2006 The MathWorks, Inc.

g = 9.83;          % acceleration of gravity (m/sec^2)
L = 67;            % pendulum length (m)
initial_x = L/100; % initial x coordinate (m)
initial_y = 0;     % initial y coordinate (m)
initial_xdot = 0;  % initial x velocity (m/sec)
initial_ydot = 0;  % initial y velocity (m/sec)
Omega=2*pi/86400;  % Earth's angular velocity of rotation about its axis (rad/sec)
lambda=49/180*pi;  % latitude in (rad)