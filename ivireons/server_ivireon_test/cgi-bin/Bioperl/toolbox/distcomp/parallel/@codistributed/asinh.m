function Y = asinh(X)
%ASINH Inverse hyperbolic sine of codistributed array
%   Y = ASINH(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.zeros(N);
%       E = asinh(D)
%   end
%   
%   See also ASINH, CODISTRIBUTED, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:00 $

Y = codistributed.pElementwiseUnaryOp(@asinh, X);

