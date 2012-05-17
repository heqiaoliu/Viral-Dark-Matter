function b = nncpy(m,n)
%NNCPY Make copies of a matrix.
%
% Obsoleted in R2006a NNET 5.0.  Last used in R2005b NNET 4.0.6.
%  
%  This function is obselete.
%  Use NNCOPY.

nnerr.obs_fcn('nncpy','Use NNCOPY(M,1).')

%  
%  *WARNING*: This function is undocumented as it may be altered
%  at any time in the future without warning.

%  NNCPY copies matrices directly as appossed to interleaving
%   the copies as done by COPYINT.
%
% NNCPY(M,N)
%   M - Matrix.
%   N - Number of copies to make.
% Returns:
%   Matrix = [M M ...] where M appears N times.
%
% EXAMPLE: M = [1 2; 3 4; 5 6];
%          n = 3;
%          X = nncpy(M,n)
%
% SEE ALSO: nncpyi, nncpyd

% Mark Beale, 12-15-93
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.11.4.1 $  $Date: 2010/03/22 04:08:02 $

[mr,mc] = size(m);
b = zeros(mr,mc*n);
ind = 1:mc;
for i=[0:(n-1)]*mc
  b(:,ind+i) = m;
end
