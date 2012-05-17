function Y = sin(X)
%SIN Sine of codistributed array in radians
%   Y = SIN(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = pi/2*codistributed.ones(N);
%       E = sin(D)
%   end
%   
%   See also SIN, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:00:36 $

Y = codistributed.pElementwiseUnaryOp(@sin, X);
