function [z,p,k] = iodynamics(D)
% Computes the s-minimal set of poles and zeros for each I/O transfer
% (with all delays set to zero).

%   Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/11/09 16:29:32 $

% RE: Return empty to avoid errors in frequency response plots 
[ny,nu,nf] = size(D.Response);
z = cell(ny,nu); z(:) = {zeros(0,1)};
p = z;
k = [];
