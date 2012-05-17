function Y = asech(X)
%ASECH Inverse hyperbolic secant of codistributed array
%   Y = ASECH(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.inf(N);
%       E = asech(D)
%   end
%   
%   See also ASECH, CODISTRIBUTED, CODISTRIBUTED/INF.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:57:57 $

Y = codistributed.pElementwiseUnaryOp(@asech, X);
