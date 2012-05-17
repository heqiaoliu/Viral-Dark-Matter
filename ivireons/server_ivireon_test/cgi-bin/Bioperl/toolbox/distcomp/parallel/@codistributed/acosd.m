function Y = acosd(X)
%ACOSD Inverse cosine of codistributed array, result in degrees
%   Y = ACOSD(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.zeros(N);
%       E = acosd(D)
%   end
%   
%   See also ACOSD, CODISTRIBUTED, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:57:43 $

if ~isreal(X)
    error('distcomp:codistributed:acosd:ComplexInput', ...
        'Argument should be real.');
end

Y = codistributed.pElementwiseUnaryOp(@acosd, X);
