function C = ldivide(A,B)
%.\ Left array divide for codistributed array matrix
%   C = A .\ B
%   C = LDIVIDE(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = codistributed.colon(1, N)'
%       D2 = D1 .\ 1 
%   end
%   
%   See also LDIVIDE, CODISTRIBUTED, CODISTRIBUTED/COLON.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:59:19 $

C = codistributed.pElementwiseBinaryOp(@ldivide,A,B);
