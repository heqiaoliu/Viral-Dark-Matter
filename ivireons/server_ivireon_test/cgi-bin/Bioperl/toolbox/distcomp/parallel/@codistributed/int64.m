function I = int64(X)
%INT64 Convert codistributed array to signed 64-bit integer
%   I = INT64(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       Du = codistributed.ones(N,'uint64');
%       Di = int64(Du)
%       classDu = classUnderlying(Du)
%       classDi = classUnderlying(Di)
%   end
%   
%   converts the N-by-N uint64 codistributed array Du to the
%   int64 codistributed array Di.
%   classDu is 'uint64' while classDi is 'int64'.
%   
%   See also INT64, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:59:12 $

I = codistributed.pElementwiseUnaryOp(@int64,X);
