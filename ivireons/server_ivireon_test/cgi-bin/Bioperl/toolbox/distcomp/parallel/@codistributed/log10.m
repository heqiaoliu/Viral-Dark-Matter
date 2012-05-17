function Y = log10(X)
%LOG10 Common (base 10) logarithm of codistributed array
%   Y = LOG10(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = 10.^codistributed.colon(1,N);
%       E = log10(D)
%   end
%   
%   See also LOG10, CODISTRIBUTED, CODISTRIBUTED/COLON.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:59:25 $

Y = codistributed.pElementwiseUnaryOp(@log10, X);
