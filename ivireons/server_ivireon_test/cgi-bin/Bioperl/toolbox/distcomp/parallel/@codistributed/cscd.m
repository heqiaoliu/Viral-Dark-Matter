function Y = cscd(X)
%CSCD Cosecant of codistributed array in degrees
%   Y = CSCD(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = cscd(D)
%   end
%   
%   See also CSCD, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:35 $

if ~isreal(X)
    error('distcomp:codistributed:cscd:ComplexInput', ...
        'Argument should be real.');
end

Y = codistributed.pElementwiseUnaryOp(@cscd, X);
