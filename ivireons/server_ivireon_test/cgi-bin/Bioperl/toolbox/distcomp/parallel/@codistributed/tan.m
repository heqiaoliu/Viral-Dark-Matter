function Y = tan(X)
%TAN Tangent of codistributed array in radians
%   Y = TAN(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = pi/4*codistributed.ones(N);
%       E = tan(D)
%   end
%   
%   See also TAN, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:01:00 $

Y = codistributed.pElementwiseUnaryOp(@tan, X);
