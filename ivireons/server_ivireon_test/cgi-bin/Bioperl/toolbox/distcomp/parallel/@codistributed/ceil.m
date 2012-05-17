function Y = ceil(X)
%CEIL Round codistributed array towards plus infinity
%   Y = CEIL(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.colon(1,N)./2
%       E = ceil(D)
%   end
%   
%   See also CEIL, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:11 $

Y = codistributed.pElementwiseUnaryOp(@ceil, X);
