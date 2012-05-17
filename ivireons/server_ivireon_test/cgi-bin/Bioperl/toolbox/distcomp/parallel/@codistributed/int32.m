function I = int32(X)
%INT32 Convert codistributed array to signed 32-bit integer
%   I = INT32(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       Du = codistributed.ones(N,'uint32');
%       Di = int32(Du)
%       classDu = classUnderlying(Du)
%       classDi = classUnderlying(Di)
%   end
%   
%   converts the N-by-N uint32 codistributed array Du to the
%   int32 codistributed array Di.
%   classDu is 'uint32' while classDi is 'int32'.
%   
%   See also INT32, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:59:11 $

I = codistributed.pElementwiseUnaryOp(@int32,X);
