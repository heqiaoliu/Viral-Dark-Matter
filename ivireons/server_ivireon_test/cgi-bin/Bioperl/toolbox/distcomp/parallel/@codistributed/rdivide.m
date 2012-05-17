function C = rdivide(A,B)
%./ Right array divide for codistributed matrix
%   C = A ./ B
%   C = RDIVIDE(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = codistributed.colon(1, N)'
%       D2 = 1 ./ D1
%   end
%   
%   See also RDIVIDE, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:00:13 $

C = codistributed.pElementwiseBinaryOp(@rdivide,A,B);
