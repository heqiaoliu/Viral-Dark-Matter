function C = ne(A,B)
%~= Not equal for codistributed array
%   C = A ~= B
%   C = NE(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.rand(N);
%       F = D ~= D
%       T = D ~= D'
%   end
%   
%   returns F = codistributed.false(N) and T is probably the same as
%   codistributed.true(N), but with the main diagonal all false
%   values.
%   
%   See also NE, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:59:37 $

C = codistributed.pElementwiseBinaryOp(@ne,A,B);
