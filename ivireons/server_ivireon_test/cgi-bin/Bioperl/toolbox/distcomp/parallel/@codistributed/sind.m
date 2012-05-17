function Y = sind(X)
%SIND Sine of codistributed array in degrees
%   Y = SIND(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = pi/2*codistributed.ones(N);
%       E = sind(D)
%   end
%   
%   See also SIND, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:00:37 $

if ~isreal(X)
    error('distcomp:codistributed:sind:ComplexInput', ...
        'Argument should be real.');
end

Y = codistributed.pElementwiseUnaryOp(@sind, X);
