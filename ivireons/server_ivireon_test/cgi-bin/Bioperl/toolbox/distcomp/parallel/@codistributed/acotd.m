function Y = acotd(X)
%ACOTD Inverse cotangent of codistributed array, result in degrees
%   Y = ACOTD(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = acotd(D)
%   end
%   
%   See also ACOTD, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:57:46 $

if ~isreal(X)
    error('distcomp:codistributed:acotd:ComplexInput', ...
        'Argument should be real.');
end

Y = codistributed.pElementwiseUnaryOp(@acotd, X);
