function I = uint64(X)
%UINT64 Convert codistributed array to unsigned 64-bit integer
%   I = UINT64(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       Di = codistributed.ones(N,'int64');
%       Du = uint64(Di)
%       classDi = classUnderlying(Di)
%       classDu = classUnderlying(Du)
%   end
%   
%   converts the N-by-N int64 codistributed array Di to the
%   uint64 codistributed array Du.
%   classDi is 'int64' while classDu is 'uint64'.
%   
%   See also UINT64, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:01:17 $

I = codistributed.pElementwiseUnaryOp(@uint64,X);
