function C = bitor(A,B)
%BITOR Bit-wise OR of codistributed array
%   C = BITOR(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = codistributed.ones(N,'uint32');
%       D2 = triu(D1);
%       D3 = bitor(D1,D2)
%   end
%   
%   See also BITOR, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:06 $

C = codistributed.pElementwiseBinaryOp(@bitor,A,B);
