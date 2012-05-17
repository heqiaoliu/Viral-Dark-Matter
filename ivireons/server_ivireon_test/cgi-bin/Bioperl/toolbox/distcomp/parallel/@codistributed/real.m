function Y = real(X)
%REAL Complex real part of codistributed array
%   Y = REAL(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = complex(3*codistributed.ones(N),4*codistributed.ones(N))
%       E = real(D)
%   end
%   
%   See also REAL, CODISTRIBUTED.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:00:17 $

Y = codistributed.pElementwiseUnaryOp(@real, X);
