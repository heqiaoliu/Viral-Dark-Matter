function [dx, f] = friction_m(t, x, v, g, varargin)
%FRICTION_M  Nonlinear friction model with Stribeck, Coulumb and viscous
%   dissipation effects.

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2007/02/06 19:51:38 $

% Output equation.
f =  g(1)*(tanh(g(2)*v(1))-tanh(g(3)*v(1))) ... % Stribeck effect.
   + g(4)*tanh(g(5)*v(1))                   ... % Coulomb effect.
   + g(6)*v(1);                                 % Viscous dissipation term.

% Static system; no states.
dx = [];