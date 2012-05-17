function C = bitxor(A,B)
%BITXOR Bit-wise XOR of codistributed array
%   C = BITXOR(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = codistributed.ones(N,'uint32');
%       D2 = triu(D1);
%       D3 = bitxor(D1,D2)
%   end
%   
%   See also BITXOR, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:07 $

C = codistributed.pElementwiseBinaryOp(@bitxor,A,B);
