function Y = abs(X)
%ABS Absolute value of codistributed array
%   Y = ABS(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = complex(3*codistributed.ones(N),4*codistributed.ones(N))
%       absD = abs(D)
%   end
%   
%   compare with
%   absD2 = sqrt(real(D).^2 + imag(D).^2)
%   
%   See also ABS, CODISTRIBUTED.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:57:41 $

Y = codistributed.pElementwiseUnaryOp(@abs, X);
