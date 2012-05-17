function Y = uminus(X)
%- Unary minus for codistributed arrays
%   B = -A
%   B = UMINUS(A)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = codistributed.eye(N);
%       D2 = -D1
%   end
%   
%   See also UMINUS, CODISTRIBUTED, CODISTRIBUTED/EYE.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:01:19 $

Y = codistributed.pElementwiseUnaryOp(@uminus, X);
