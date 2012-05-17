function [dx, y] = signaltransmission_m(t, x, u, L, C, varargin)
%SIGNALTRANSMISSION_M  Discretized (in distance) "Telegraph" equation.

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:29:10 $

% Determine the number of discretization points and the distance between
% the discretization points using N and L from varargin.
N = varargin{1}{1}.N;
h = varargin{1}{1}.L/N;

% Output equation.
y = x(end);   % Voltage at the end of the transmitter.

% State equations.
dx = zeros(2*N, 1);
Lh = -1/(L*h);
Ch = -1/(C*h);
for j = 1:2:2*N
    if (j == 1)
        dx(j)   = Lh*(x(j+1)-u);
        dx(j+1) = Ch*(x(j+2)-x(j));
    elseif (j < 2*(N-1))
        dx(j)   = Lh*(x(j+1)-x(j-1));
        dx(j+1) = Ch*(x(j+2)-x(j));
    else
        dx(j)   = Lh*(x(j+1)-x(j-1));
        dx(j+1) = -Ch*x(j);
    end
end