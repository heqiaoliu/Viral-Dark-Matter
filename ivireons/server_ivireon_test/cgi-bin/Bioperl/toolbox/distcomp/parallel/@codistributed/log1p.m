function y = log1p(z)
%LOG1P Compute log(1+z) accurately of codistributed array
%   Y = LOG1P(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = eps(1) .* codistributed.ones(N);
%       E = log1p(D)
%   end
%   
%   See also LOG1P, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:59:26 $

y = codistributed.pElementwiseUnaryOp(@log1p, z);
