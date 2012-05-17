function C = ge(A,B)
%>= Greater than or equal for codistributed array
%   C = A >= B
%   C = GE(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.rand(N);
%       T = D >= D
%       F = D >= D+0.5
%   end
%   
%   returns T = codistributed.true(N)
%   and F = codistributed.false(N).
%   
%   See also GE, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:59:01 $

C = codistributed.pElementwiseBinaryOp(@ge,A,B);
