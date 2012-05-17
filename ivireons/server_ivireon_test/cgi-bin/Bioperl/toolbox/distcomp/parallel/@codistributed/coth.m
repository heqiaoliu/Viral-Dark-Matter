function Y = coth(X)
%COTH Hyperbolic cotangent of codistributed array
%   Y = COTH(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.inf(N);
%       E = coth(D)
%   end
%   
%   See also COTH, CODISTRIBUTED, CODISTRIBUTED/INF.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:33 $

Y = codistributed.pElementwiseUnaryOp(@coth, X);
