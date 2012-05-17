function [N,rho] = splitDelay(tau,Ts)
% Decomposes continuous delays as tau = (N + rho) * Ts
% with N integer and 0<=rho<1.

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision $  $Date: 2009/11/09 16:28:58 $

% TOLINT: rounding tolerance for entire time delay
tolint = 1e4*eps;

% Compute discrete input and output delays
dtau = tau/Ts;
N = floor(dtau+tolint);
rho = dtau - N;
rho(rho<tolint) = 0;
