function Y = atanh(X)
%ATANH Inverse hyperbolic tangent of codistributed array
%   Y = ATANH(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = atanh(D)
%   end
%   
%   See also ATANH, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:04 $

Y = codistributed.pElementwiseUnaryOp(@atanh, X);
