function Z = xor(X,Y)
%XOR Logical EXCLUSIVE OR for codistributed array
%   C = XOR(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = codistributed.eye(N);
%       D2 = codistributed.rand(N);
%       D3 = xor(D1,D2)
%   end
%   
%   See also XOR, CODISTRIBUTED, CODISTRIBUTED/EYE.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:01:21 $

Z = codistributed.pElementwiseBinaryOp(@xor,X,Y);
