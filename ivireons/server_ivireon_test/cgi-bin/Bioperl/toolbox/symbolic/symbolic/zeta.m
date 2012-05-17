function Z = zeta(n,X)
%ZETA   Symbolic Riemann zeta function.
%   ZETA(z) = sum(1/k^z,k,1,inf).
%   ZETA(n,z) = n-th derivative of ZETA(z)

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/09 20:41:56 $

if nargin == 1
   Z = double(zeta(sym(n)));
else
   Z = double(zeta(sym(n),sym(X)));
end
