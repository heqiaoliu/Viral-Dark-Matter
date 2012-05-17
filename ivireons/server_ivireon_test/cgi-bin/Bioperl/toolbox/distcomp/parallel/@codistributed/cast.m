function D2 = cast(D1,className)
%CAST Cast a codistributed array to a different data type or class
%   B = CAST(A,NEWCLASS)
%   
%   Example:
%   spmd
%       N = 1000;
%       Du = codistributed.ones(N,'uint32');
%       Ds = cast(Du,'single')
%       classDu = classUnderlying(Du)
%       classDs = classUnderlying(Ds)
%   end
%   
%   casts the codistributed uint32 array Du to the codistributed single array
%   Ds. classDu is 'uint32', while classDs is 'single'.
%   
%   See also CAST, CODISTRIBUTED, CODISTRIBUTED/ONES, 
%   CODISTRIBUTED/CLASSUNDERLYING.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/05/14 16:50:54 $
className = distributedutil.CodistParser.gatherIfCodistributed(className);
if ~isa(D1, 'codistributed')
    D2 = cast(D1, className);
    return;
end

D2 = codistributed.pElementwiseUnaryOpWithCatch(@(x)cast(x,className),D1); %#ok<DCUNK> private static
