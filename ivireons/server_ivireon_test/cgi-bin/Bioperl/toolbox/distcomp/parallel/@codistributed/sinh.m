function Y = sinh(X)
%SINH Hyperbolic sine of codistributed array
%   Y = SINH(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.inf(N);
%       E = sinh(D)
%   end
%   
%   See also SINH, CODISTRIBUTED, CODISTRIBUTED/INF.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:00:39 $

Y = codistributed.pElementwiseUnaryOp(@sinh, X);
