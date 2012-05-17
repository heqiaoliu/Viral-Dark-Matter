function D = single(A)
%SINGLE Convert codistributed array to single precision
%   S = SINGLE(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       Du = codistributed.ones(N,'uint32');
%       Ds = single(Du)
%       classDu = classUnderlying(Du)
%       classDs = classUnderlying(Ds)
%   end
%   
%   converts the N-by-N uint32 codistributed array Du to the
%   single codistributed array Ds.
%   classDu is 'uint32' while classDs is 'single'.
%   
%   See also SINGLE, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:00:38 $

D = codistributed.pElementwiseUnaryOp(@single,A);
