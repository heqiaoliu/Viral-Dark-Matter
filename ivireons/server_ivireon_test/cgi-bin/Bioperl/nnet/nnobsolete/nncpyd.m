function y = nncpyd(x)
%NNCPYD Copy vectors in a matrix onto diagonals.
%
% Obsoleted in R2006a NNET 5.0.  Last used in R2005b NNET 4.0.6.
%  
%  This function is obselete.

nnerr.obs_fcn('nncpyd','')
  
%  *WARNING*: This function is undocumented as it may be altered
%  at any time in the future without warning.

% NNCPYD(X)
%   X - NxM Matrix of column vectors.
% Returns Nx(N*M) matrix of M NxN diagonal matrices
%   with the columns of X on each diagonal.
%
% EXAMPLE: X = [1 2; 3 4; 5 6];
%          Y = nncpyd(X)
%
% SEE ALSO: nncpy, nncpyi

% Mark Beale, 12-15-93
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.11.4.1 $  $Date: 2010/03/22 04:08:03 $

[xr,xc] = size(x);

y = zeros(xr,xr*xc);

i = 1:xr;
for j=0:xr:((xc-1)*xr)
  y(i+(i+j-1)*xr) = x(i+j);
end
