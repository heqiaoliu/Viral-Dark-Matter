function y = nthroot(x, n)
%NTHROOT Real n-th root of real numbers
%   Y = NTHROOT(X,N)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = -2*codistributed.ones(N);
%       E = D.^(1/3)
%       F = nthroot(D,3)
%   end
%   
%   See also NTHROOT, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:59:44 $

if ~isreal(x) || ~isreal(n)
   error('distcomp:codistributed:nthroot:ComplexInput', ...
       'Both X and N must be real.');
end

y = codistributed.pElementwiseBinaryOp(@nthroot, x, n);
