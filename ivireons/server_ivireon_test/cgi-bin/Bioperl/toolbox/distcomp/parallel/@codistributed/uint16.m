function I = uint16(X)
%UINT16 Convert codistributed array to unsigned 16-bit integer
%   I = UINT16(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       Di = codistributed.ones(N,'int16');
%       Du = uint16(Di)
%       classDi = classUnderlying(Di)
%       classDu = classUnderlying(Du)
%   end
%   
%   converts the N-by-N int16 codistributed array Di to the
%   uint16 codistributed array Du.
%   classDi is 'int16' while classDu is 'uint16'.
%   
%   See also UINT16, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:01:13 $

I = codistributed.pElementwiseUnaryOp(@uint16,X);
