function Y = acosh(X)
%ACOSH Inverse hyperbolic cosine of codistributed array
%   Y = ACOSH(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.zeros(N);
%       E = acosh(D)
%   end
%   
%   See also ACOSH, CODISTRIBUTED, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:57:44 $

Y = codistributed.pElementwiseUnaryOp(@acosh, X);
