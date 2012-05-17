function Y = asind(X)
%ASIND Inverse sine of codistributed array, result in degrees
%   Y = ASIND(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = asind(D)
%   end
%   
%   See also ASIND, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:57:59 $

if ~isreal(X)
    error('distcomp:codistributed:asind:ComplexInput', ...
        'Argument should be real.');
end

Y = codistributed.pElementwiseUnaryOp(@asind, X);

