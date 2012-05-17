function Y = sqrt(X)
%SQRT Square root of codistributed array
%   Y = SQRT(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = -codistributed.ones(N)
%       E = sqrt(D)
%   end
%   
%   See also SQRT, CODISTRIBUTED.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:00:50 $

Y = codistributed.pElementwiseUnaryOp(@sqrt, X);
