function [c, ceq, K, s] = uncertainAirPollutionCon(h, s)
%UNCERTAINAIRPOLLUTIONCON Constraint function for air pollution demo
% 
%   [C, CEQ, K, S] = UNCERTAINAIRPOLLUTIONCON(H, S) calculates the
%   constraints for the fseminf Optimization Toolbox (TM) demo. This
%   function first creates a grid of wind speed/direction points using the
%   supplied grid spacing, S. The following constraint is then calculated
%   over each point of the grid:
%
%   Sulfur Dioxide concentration at x = -20000m, y = 20000m <= 1.25e-4
%   g/m^3
%
%   See also AIRPOLLUTIONCON, AIRPOLLUTION

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/01/08 18:46:24 $

% Maximum allowed sulphur dioxide
maxsul = 1.25e-4; 

% Initial sampling interval
if nargin < 2 || isnan(s(1,1))
    s = [0.02 0.04]; 
end

% Define the grid that the "infinite" constraints will be evaluated over
w1x = 3.82:s(1,1):4.18; % Wind direction
w1y = 5.0:s(1,2):6.2;   % Wind speed
[t1,t2] = meshgrid(w1x,w1y);

% We assume the maximum SO2 concentration is at [x, y] = [-20000, 20000]
% for all wind speed/direction pairs. We evaluate the SO2 constraint over
% the [theta, U] grid at this point.
K = concSulfurDioxide(-20000, 20000, h, t1, t2) - maxsul;
 
% Rescale constraint to make it 0(1)
K = 1e4*K;

% No finite constraints
c = [];
ceq = [];

