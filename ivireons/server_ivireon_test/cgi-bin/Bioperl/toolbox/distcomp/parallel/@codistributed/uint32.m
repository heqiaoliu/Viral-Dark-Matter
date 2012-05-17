function I = uint32(X)
%UINT32 Convert codistributed array to unsigned 32-bit integer
%   I = UINT32(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       Di = codistributed.ones(N,'int32');
%       Du = uint32(Di)
%       classDi = classUnderlying(Di)
%       classDu = classUnderlying(Du)
%   end
%   
%   converts the N-by-N int32 codistributed array Di to the
%   uint32 codistributed array Du.
%   classDi is 'int32' while classDu is 'uint32'.
%   
%   See also UINT32, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:01:14 $

I = codistributed.pElementwiseUnaryOp(@uint32,X);
