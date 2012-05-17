function Z = or(X,Y)
%| Logical OR for codistributed array
%   C = A | B
%   C = OR(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = codistributed.eye(N);
%       D2 = codistributed.rand(N);
%       D3 = D1 | D2
%   end
%   
%   returns D3 = codistributed.true(N).
%   
%   See also OR, CODISTRIBUTED, CODISTRIBUTED/EYE.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:59:49 $

Z = codistributed.pElementwiseBinaryOp(@or,X,Y);
