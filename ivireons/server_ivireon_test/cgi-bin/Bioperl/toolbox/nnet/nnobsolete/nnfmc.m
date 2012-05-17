function i = nnfmc(m)
%NNFMC Find largest column vector in matrix.
%
% Obsoleted in R2006a NNET 5.0.  Last used in R2005b NNET 4.0.6.
%  
%  This function is obselete.
%  Use FIND(SUM(M .^ 2) == MAX(SUM(M .^ 2))) instead.

nnerr.obs_fcn('nnfmc','Use FIND(SUM(M .^ 2) == MAX(SUM(M .^ 2))) instead.')

% NNFMC(M)
%   M - Matrix of columns: [C1 C2 ... Cn]
% Returns index i of the largest vector Ci.
%
% EXAMPLE: M = [1 3 5; 2 4 -10];
%          index = nnfmc(M)

% Mark Beale, 12-15-93
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.6.4.1 $  $Date: 2010/03/22 04:08:06 $

replace = find(isnan(m));
m(replace) = zeros(size(replace));

[mr,mc] = size(m);

if mr > 1
  m = sum(m .^ 2);
end

i = find(m == max(m));
i = i(1);
