function A = compan(c)
%COMPAN Companion matrix.
%   COMPAN(P) is a companion matrix of the polynomial
%   with coefficients P.
%
%   Class support for input P:
%      float: double, single

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.7.4.2 $  $Date: 2004/07/05 17:01:12 $

if min(size(c)) > 1
    error('MATLAB:compan:NeedVectorInput', 'Input argument must be a vector.')
end
n = length(c);
if n <= 1
   A = zeros(0,0,superiorfloat(c));
elseif n == 2
   A = -c(2)/c(1);
else
   c = c(:).';     % make sure it's a row vector
   A = diag(ones(1,n-2,superiorfloat(c)),-1);
   A(1,:) = -c(2:n) ./ c(1);
end
