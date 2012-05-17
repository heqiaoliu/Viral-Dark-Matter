function Y = cosd(X)
%COSD Cosine of codistributed array in degrees
%   Y = COSD(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.zeros(N);
%       E = cosd(D)
%   end
%   
%   See also COSD, CODISTRIBUTED, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:29 $

if ~isreal(X)
    error('distcomp:codistributed:cosd:ComplexInput', ...
        'Argument should be real.');
end

Y = codistributed.pElementwiseUnaryOp(@cosd, X);
