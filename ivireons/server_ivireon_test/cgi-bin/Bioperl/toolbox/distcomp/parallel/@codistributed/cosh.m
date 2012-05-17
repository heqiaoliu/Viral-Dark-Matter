function Y = cosh(X)
%COSH Hyperbolic cosine of codistributed array
%   Y = COSH(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.zeros(N);
%       E = cosh(D)
%   end
%   
%   See also COSH, CODISTRIBUTED, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:30 $

Y = codistributed.pElementwiseUnaryOp(@cosh, X);
