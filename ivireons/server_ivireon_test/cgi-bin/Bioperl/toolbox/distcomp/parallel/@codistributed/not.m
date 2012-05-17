function Y = not(X)
%~ Logical NOT for codistributed array
%   B = ~A
%   B = NOT(A)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.eye(N);
%       E = ~D
%   end
%   
%   See also NOT, CODISTRIBUTED, CODISTRIBUTED/EYE.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:59:43 $

Y = codistributed.pElementwiseUnaryOp(@not,X);
