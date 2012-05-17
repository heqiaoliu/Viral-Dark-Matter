function Y = acos(X)
%ACOS Inverse cosine of codistributed array, result in radians
%   Y = ACOS(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.zeros(N);
%       E = acos(D)
%   end
%   
%   See also ACOS, CODISTRIBUTED, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:57:42 $

Y = codistributed.pElementwiseUnaryOp(@acos, X);
