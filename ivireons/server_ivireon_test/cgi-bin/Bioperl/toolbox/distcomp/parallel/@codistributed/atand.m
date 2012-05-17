function Y = atand(X)
%ATAND Inverse tangent of codistributed array, result in degrees
%   Y = ATAND(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = atand(D)
%   end
%   
%   See also ATAND, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:03 $

if ~isreal(X)
    error('distcomp:codistributed:atand:ComplexInput', ...
       'Argument should be real.');
end

Y = codistributed.pElementwiseUnaryOp(@atand, X);
