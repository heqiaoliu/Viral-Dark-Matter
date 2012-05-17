function Y = csch(X)
%CSCH Hyperbolic cosecant of codistributed array
%   Y = CSCH(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.inf(N);
%       E = csch(D)
%   end
%   
%   See also CSCH, CODISTRIBUTED, CODISTRIBUTED/INF.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:36 $

Y = codistributed.pElementwiseUnaryOp(@csch, X);
