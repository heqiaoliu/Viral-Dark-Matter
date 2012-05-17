function Y = secd(X)
%SECD Secant of codistributed array in degrees
%   Y = SECD(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.zeros(N);
%       E = secd(D)
%   end
%   
%   See also SECD, CODISTRIBUTED, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:00:32 $

if ~isreal(X)
    error('distcomp:codistributed:secd:ComplexInput', ...
        'Argument should be real.');
end

Y = codistributed.pElementwiseUnaryOp(@secd, X);
