function [dx, y] = dcmotor_m(t, x, u, tau, k, varargin)
%DCMOTOR_M  The same DC-motor that was modeled by IDGREY of SITB.

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:28:49 $

% Output equations.
y = [x(1);                         ... % Angular position.
     x(2)                          ... % Angular velocity.
    ];

% State equations.
dx = [x(2);                        ... % Angular position.
      -(1/tau)*x(2)+(k/tau)*u(1)   ... % Angular velocity.
     ];