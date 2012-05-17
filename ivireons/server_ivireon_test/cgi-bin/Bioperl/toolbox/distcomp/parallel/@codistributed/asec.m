function Y = asec(X)
%ASEC Inverse secant of codistributed array, result in radians
%   Y = ASEC(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = asec(D)
%   end
%   
%   See also ASEC, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:57:55 $

Y = codistributed.pElementwiseUnaryOp(@asec, X);
