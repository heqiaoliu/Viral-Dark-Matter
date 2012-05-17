function [dx, y] = cstr_m(t, x, u, F, V, k_0, E, R, H, HD, HA, varargin)
%CSTR_M  A non-adiabatic Continuous Stirred Tank Reactor (CSTR).

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:28:47 $

% Output equations.
y = [x(1);               ... % Concentration of substance A in the reactor.
     x(2)                ... % Reactor temperature.
    ];

% State equations.
dx = [F/V*(u(1)-x(1))-k_0*exp(-E/(R*x(2)))*x(1); ...
      F/V*(u(2)-x(2))-(H/HD)*k_0*exp(-E/(R*x(2)))*x(1)-(HA/(HD*V))*(x(2)-u(3)) ...
     ];