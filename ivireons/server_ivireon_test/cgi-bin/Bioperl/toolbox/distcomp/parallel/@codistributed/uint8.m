function I = uint8(X)
%UINT8 Convert codistributed array to unsigned 8-bit integer
%   I = UINT8(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       Di = codistributed.ones(N,'int8');
%       Du = uint8(Di)
%       classDi = classUnderlying(Di)
%       classDu = classUnderlying(Du)
%   end
%   
%   converts the N-by-N int8 codistributed array Di to the
%   uint8 codistributed array Du.
%   classDi is 'int8' while classDu is 'uint8'.
%   
%   See also UINT8, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:01:18 $

I = codistributed.pElementwiseUnaryOp(@uint8,X);
