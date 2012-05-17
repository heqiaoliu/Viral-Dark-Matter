function [g,factor,power] = dcgain(PID)
% Computes DC gain and DC equivalent.

%   Author(s): Rong Chen
%   Copyright 2009 MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2010/02/08 22:47:15 $

% convert to internal parameterization
[P I] = utGetPIDT(PID);
% s=0 or z=1
if I==0
    % no integrator
    g = P;
    factor = P;
    power = 0;
else
    % has integrator
    g = inf;
    factor = I*(abs(PID.Ts))^(PID.Ts~=0); % I times Ts if discrete time
    power = -1;
end

