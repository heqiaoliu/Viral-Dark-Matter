function C = plus(A,B)
%+ Plus for codistributed array
%   C = A + B
%   C = PLUS(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = codistributed.ones(N);
%       D2 = 2*D1
%       D3 = D1 + D2
%   end
%   
%   See also PLUS, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:59:59 $

C = codistributed.pElementwiseBinaryOp(@plus,A,B);
