function L = logical(D)
%LOGICAL Convert numeric values of codistributed array to logical
%   L = LOGICAL(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       Du = codistributed.ones(N,'uint8');
%       Dl = logical(Du)
%       classDu = classUnderlying(Du)
%       classDl = classUnderlying(Dl)
%   end
%   
%   converts the N-by-N uint8 codistributed array Du to the
%   logical codistributed array Dl.
%   classDu is 'uint8' while classDl is 'logical'.
%   
%   See also LOGICAL, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:59:28 $

if isscalar(D)
    L = logical(gather(D));
else
    L = codistributed.pElementwiseUnaryOpWithCatch(@logical,D);
end
