function Y = realsqrt(X)
%REALSQRT Real square root of codistributed array
%   Y = REALSQRT(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = -4*codistributed.ones(N)
%       try realsqrt(D), catch, disp('negative input!'), end
%       E = realsqrt(-D)
%   end
%   
%   See also REALSQRT, CODISTRIBUTED.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:00:22 $

Y = codistributed.pElementwiseUnaryOpWithCatch(@realsqrt, X);
