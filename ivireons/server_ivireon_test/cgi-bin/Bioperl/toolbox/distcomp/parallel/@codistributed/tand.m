function Y = tand(X)
%TAND Tangent of codistributed array in degrees
%   Y = TAND(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = 45*codistributed.ones(N);
%       E = tand(D)
%   end
%   
%   See also TAND, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:01:01 $

if ~isreal(X)
    error('distcomp:codistributed:tand:ComplexInput', ...
        'Argument should be real.');
end

Y = codistributed.pElementwiseUnaryOp(@tand, X);
