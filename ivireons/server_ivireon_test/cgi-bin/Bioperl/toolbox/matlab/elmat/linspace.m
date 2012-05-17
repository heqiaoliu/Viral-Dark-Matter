function y = linspace(d1, d2, n)
%LINSPACE Linearly spaced vector.
%   LINSPACE(X1, X2) generates a row vector of 100 linearly
%   equally spaced points between X1 and X2.
%
%   LINSPACE(X1, X2, N) generates N points between X1 and X2.
%   For N < 2, LINSPACE returns X2.
%
%   Class support for inputs X1,X2:
%      float: double, single
%
%   See also LOGSPACE, COLON.

%   Copyright 1984-2010 The MathWorks, Inc. a
%   $Revision: 5.12.4.2 $  $Date: 2010/04/21 21:31:40 $

if nargin == 2
    n = 100;
end
n = double(n);
n1 = floor(n)-1;
vec = 0:n-2;
if isinf(d2 - d1) 
    y = [d1 + (d2/n1).*vec - (d1/n1).*vec, d2]; % overflow for d1 < 0 and d2 > 0
else
    y = [d1 + (vec.*(d2-d1)/n1), d2];
end
