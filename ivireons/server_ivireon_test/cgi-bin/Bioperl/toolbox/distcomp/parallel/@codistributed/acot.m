function Y = acot(X)
%ACOT Inverse cotangent of codistributed array, result in radians
%   Y = ACOT(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = acot(D)
%   end
%   
%   See also ACOT, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:57:45 $

Y = codistributed.pElementwiseUnaryOp(@acot, X);
