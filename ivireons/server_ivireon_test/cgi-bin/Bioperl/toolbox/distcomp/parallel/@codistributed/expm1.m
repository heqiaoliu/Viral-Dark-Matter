function y = expm1(z)
%EXPM1 Compute exp(z)-1 accurately for codistributed array
%   Y = EXPM1(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = eps(1) .* codistributed.ones(N);
%       E = expm1(D)
%   end
%   
%   See also EXPM1, CODISTRIBUTED.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:50 $

y = codistributed.pElementwiseUnaryOp(@expm1, z);
