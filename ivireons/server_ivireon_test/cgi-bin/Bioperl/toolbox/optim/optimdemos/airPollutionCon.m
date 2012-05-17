function [c, ceq, K, s] = airPollutionCon(h, s, theta, U)
%AIRPOLLUTIONCON Constraint function for air pollution demo
% 
%   [C, CEQ, K, S] = AIRPOLLUTIONCON(H, S, THETA, U) calculates the
%   constraints for the air pollution Optimization Toolbox (TM) demo. This
%   function first creates a grid of (X, Y) points using the supplied grid
%   spacing, S. The following constraint is then calculated over each point
%   of the grid:
%
%   Sulfur Dioxide concentration at the specified wind direction, THETA and
%   wind speed U <= 1.25e-4 g/m^3
%
%   See also AIRPOLLUTION

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/01/08 18:46:20 $

% Initial sampling interval
if nargin < 2 || isnan(s(1,1))
    s = [1000 4000]; 
end

% Define the grid that the "infinite" constraints will be evaluated over
w1x = -20000:s(1,1):20000;
w1y = -20000:s(1,2):20000;
[t1,t2] = meshgrid(w1x,w1y);

% Maximum allowed sulphur dioxide
maxsul = 1.25e-4; 

% Calculate the constraint over the grid
K = concSulfurDioxide(t1, t2, h, theta, U) - maxsul;

% Rescale constraint to make it 0(1)
K = 1e4*K;

% No finite constraints
c = [];
ceq = [];