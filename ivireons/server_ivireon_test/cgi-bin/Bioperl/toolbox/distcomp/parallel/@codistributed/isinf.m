function Y = isinf(X)
%ISINF True for infinite elements of codistributed array
%   TF = ISINF(D)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.inf(N);
%       T = isinf(D)
%   end
%   
%   returns T = codistributed.true(size(D)).
%   
%   See also ISINF, CODISTRIBUTED, CODISTRIBUTED/INF.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:59:15 $

Y = codistributed.pElementwiseUnaryOp(@isinf,X);
