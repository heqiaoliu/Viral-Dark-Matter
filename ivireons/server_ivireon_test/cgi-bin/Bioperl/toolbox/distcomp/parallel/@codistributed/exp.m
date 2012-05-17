function Y = exp(X)
%EXP Exponential of codistributed array
%   Y = EXP(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = exp(D)
%   end
%   
%   See also EXP, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:49 $

Y = codistributed.pElementwiseUnaryOp(@exp, X);
