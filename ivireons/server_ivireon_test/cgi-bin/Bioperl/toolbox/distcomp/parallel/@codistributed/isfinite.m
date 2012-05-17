function y = isfinite(A)
%ISFINITE True for finite elements of codistributed array
%   TF = ISFINITE(D)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       T = isfinite(D)
%   end
%   
%   returns T = codistributed.true(size(D)).
%   
%   See also ISFINITE, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:59:14 $

y = codistributed.pElementwiseUnaryOp(@isfinite,A);
