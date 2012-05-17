function P = pei(n, alpha, classname)
%PEI    Pei matrix.
%   GALLERY('PEI',N,ALPHA), where ALPHA is a scalar, is the symmetric
%   matrix ALPHA*EYE(N) + ONES(N). The default for ALPHA is 1.
%   The matrix is singular for ALPHA = 0, -N.

%   Reference:
%   M. L. Pei, A test matrix for inversion procedures, Comm. ACM,
%   5 (1962), p. 508.
%
%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2005/11/18 14:15:19 $

if isempty(alpha), alpha = 1; end

P = alpha*eye(n,classname) + ones(n,classname);
