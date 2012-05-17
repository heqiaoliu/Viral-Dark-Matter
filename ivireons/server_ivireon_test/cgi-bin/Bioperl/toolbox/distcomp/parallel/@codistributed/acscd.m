function Y = acscd(X)
%ACSCD Inverse cosecant of codistributed array, result in degrees
%   Y = ACSCD(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = acscd(D)
%   end
%   
%   See also ACSCD, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:57:49 $

if ~isreal(X)
    error('distcomp:codistributed:acscd:ComplexInput', ...
        'Argument should be real.');
end

Y = codistributed.pElementwiseUnaryOp(@acscd, X);
