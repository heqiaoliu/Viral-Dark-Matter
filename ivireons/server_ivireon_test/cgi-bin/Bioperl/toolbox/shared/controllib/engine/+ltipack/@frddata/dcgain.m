function [g,factor,power] = dcgain(D)
% Computes DC gain and DC equivalent

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:16 $
[ny,nu,nf] = size(D.Response);
g = zeros(ny,nu); g(:) = NaN;
factor = zeros(ny,nu); factor(:) = NaN;
power = zeros(ny,nu); power(:) = NaN;