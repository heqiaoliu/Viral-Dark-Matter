function I = int16(X)
%INT16 Convert codistributed array to signed 16-bit integer
%   I = INT16(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       Du = codistributed.ones(N,'uint16');
%       Di = int16(Du)
%       classDu = classUnderlying(Du)
%       classDi = classUnderlying(Di)
%   end
%   
%   converts the N-by-N uint16 codistributed array Du to the
%   int16 codistributed array Di.
%   classDu is 'uint16' while classDi is 'int16'.
%   
%   See also INT16, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:59:10 $

I = codistributed.pElementwiseUnaryOp(@int16,X);
