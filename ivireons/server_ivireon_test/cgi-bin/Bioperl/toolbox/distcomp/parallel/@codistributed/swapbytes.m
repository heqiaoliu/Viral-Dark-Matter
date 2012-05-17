function out = swapbytes(in)
%SWAPBYTES Swap byte ordering, changing endianness of codistributed array
%   Y = SWAPBYTES(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N,'uint16');
%       E = swapbytes(D)
%       classD = classUnderlying(D)
%       classE = classUnderlying(E)
%   end
%   
%   swaps the bytes of the uint16(1) values of D into uint16(256).
%   classD and classE are both uint16.
%   
%   See also SWAPBYTES, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:00:58 $

out = codistributed.pElementwiseUnaryOp(@swapbytes, in);
