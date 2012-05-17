function Y = uplus(X)
%+ Unary plus for codistributed array
%   B = +A
%   B = UPLUS(A)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = codistributed.eye(N);
%       D2 = +D1
%   end
%   
%   See also UPLUS, CODISTRIBUTED, CODISTRIBUTED/EYE.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:01:20 $

Y = codistributed.pElementwiseUnaryOp(@uplus, X);
