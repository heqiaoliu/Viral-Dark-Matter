function C = bitand(A,B)
%BITAND Bit-wise AND of codistributed array
%   C = BITAND(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = codistributed.ones(N,'uint32');
%       D2 = triu(D1);
%       D3 = bitand(D1,D2)
%   end
%   
%   See also BITAND, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:05 $

C = codistributed.pElementwiseBinaryOp(@bitand,A,B);
