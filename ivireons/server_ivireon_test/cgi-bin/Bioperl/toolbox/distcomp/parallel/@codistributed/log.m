function Y = log(X)
%LOG Natural logarithm of codistributed array
%   Y = LOG(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = log(D)
%   end
%   
%   See also LOG, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:59:24 $

Y = codistributed.pElementwiseUnaryOp(@log, X);
