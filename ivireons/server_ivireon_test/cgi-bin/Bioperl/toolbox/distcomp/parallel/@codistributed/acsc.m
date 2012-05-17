function Y = acsc(X)
%ACSC Inverse cosecant of codistributed array, result in radian
%   Y = ACSC(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = acsc(D)
%   end
%   
%   See also ACSC, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:57:48 $

Y = codistributed.pElementwiseUnaryOp(@acsc, X);
