function Y = cotd(X)
%COTD Cotangent of codistributed array in degrees
%   Y = COTD(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = cotd(D)
%   end
%   
%   See also COTD, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:32 $

if ~isreal(X)
    error('distcomp:codistributed:cotd:ComplexInput', ...
        'Argument should be real.');
end

Y = codistributed.pElementwiseUnaryOp(@cotd, X);
