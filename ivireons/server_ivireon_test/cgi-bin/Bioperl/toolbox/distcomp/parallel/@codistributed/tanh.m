function Y = tanh(X)
%TANH Hyperbolic tangent of codistributed array
%   Y = TANH(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.inf(N);
%       E = tanh(D)
%   end
%   
%   See also TANH, CODISTRIBUTED, CODISTRIBUTED/INF.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:01:02 $

Y = codistributed.pElementwiseUnaryOp(@tanh, X);
