function Y = acsch(X)
%ACSCH Inverse hyperbolic cosecant of codistributed array
%   Y = ACSCH(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.inf(N);
%       E = acsch(D)
%   end
%   
%   See also ACSCH, CODISTRIBUTED, CODISTRIBUTED/INF.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:57:50 $

Y = codistributed.pElementwiseUnaryOp(@acsch, X);
