function Y = asecd(X)
%ASECD Inverse secant of codistributed array, result in degrees
%   Y = ASECD(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = asecd(D)
%   end
%   
%   See also ASECD, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:57:56 $

if ~isreal(X)
    error('distcomp:codistributed:asecd:ComplexInput', ...
        'Argument should be real.');
end

Y = codistributed.pElementwiseUnaryOp(@asecd, X);

