function Y = isnan(X)
%ISNAN True for Not-a-Number elements of codistributed array
%   TF = ISNAN(D)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.nan(N);
%       T = isnan(D)
%   end
%   
%   returns T = codistributed.true(size(D)).
%   
%   See also ISNAN, CODISTRIBUTED, CODISTRIBUTED/NAN.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:59:16 $

Y = codistributed.pElementwiseUnaryOp(@isnan,X);
