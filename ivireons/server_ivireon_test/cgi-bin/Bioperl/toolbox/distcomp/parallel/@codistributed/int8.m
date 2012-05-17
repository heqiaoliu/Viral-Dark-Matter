function I = int8(X)
%INT8 Convert codistributed array to signed 8-bit integer
%   I = INT8(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       Du = codistributed.ones(N,'uint8');
%       Di = int8(Du)
%       classDu = classUnderlying(Du)
%       classDi = classUnderlying(Di)
%   end
%   
%   converts the N-by-N uint8 codistributed array Du to the
%   int8 codistributed array Di.
%   classDu is 'uint8' while classDi is 'int8'.
%   
%   See also INT8, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:59:13 $

I = codistributed.pElementwiseUnaryOp(@int8,X);
