function Y = fix(X)
%FIX Round codistributed array towards zero
%   Y = FIX(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.colon(1,N)./2
%       E = fix(D)
%   end
%   
%   See also FIX, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:57 $

Y = codistributed.pElementwiseUnaryOp(@fix, X);
