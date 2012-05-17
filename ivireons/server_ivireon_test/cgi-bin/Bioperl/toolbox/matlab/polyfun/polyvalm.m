function Y = polyvalm(p,X)
%POLYVALM Evaluate polynomial with matrix argument.
%   Y = POLYVALM(P,X), when P is a vector of length N+1 whose elements
%   are the coefficients of a polynomial, is the value of the
%   polynomial evaluated with matrix argument X.  X must be a 
%   square matrix. 
%
%       Y = P(1)*X^N + P(2)*X^(N-1) + ... + P(N)*X + P(N+1)*I
%
%   Class support for inputs p, X:
%      float: double, single
%
%   See also POLYVAL, POLYFIT.

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 5.11.4.4 $  $Date: 2007/09/18 02:17:01 $

% Polynomial evaluation p(x) using Horner's method.

% Check input is a vector
if ~(isvector(p) || isempty(p))
    error('MATLAB:polyvalm:InvalidP',...
            'P must be a vector.');
end

np = length(p);
[m,n] = size(X);
if m ~= n
    error('MATLAB:polyvalm:NonSquareMatrix', 'Matrix must be square.')
end

if np == 1    %Quick return if possible.
    Y = diag(p(1) * ones(m,1,superiorfloat(p,X))); 
    return
end    

Y = zeros(m,superiorfloat(p,X));
for i = 1:np
    Y = X * Y + diag(p(i) * ones(m,1));
end
