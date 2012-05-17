function D = spfun(fun, D)
%SPFUN Apply function to nonzero codistributed matrix elements
%   D2 = SPFUN(FUN,D)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.sprand(N, N, 0.2)
%       F = spfun(@exp, D)
%   end
%   
%   F has the same sparsity pattern as D (except for underflow), whereas 
%   EXP(D) has 1's where D has 0's.
%   
%   See also SPFUN, CODISTRIBUTED, CODISTRIBUTED/SPRAND.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/08/29 08:23:43 $

% Input may be full or sparse.  Guard against ND-full input.
if ndims(D) > 2
    error('distcomp:codistributed:spfun:NDNotSupported', ...
          'N-D sparse is not supported.');
end
LP = getLocalPart(D);
codistr = getCodistributor(D);
clear D;

% Apply spfun to all the parts of the array, redistribute if necessary.
sparsifyFcn = @(x) spfun(fun, x);
procFcn = @() codistr.hSparsifyImpl(sparsifyFcn, LP);
% Call hSparsifyImpl with two output arguments, but synchronize the error
% behavior because it is possible that fun throws an error.
[LP, codistr] = distributedutil.syncOnError(procFcn);

D = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK>
