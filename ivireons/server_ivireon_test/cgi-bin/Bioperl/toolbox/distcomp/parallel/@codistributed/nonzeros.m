function nzs = nonzeros(S)
%NONZEROS Nonzero codistributed matrix elements
%   NZ = NONZEROS(D)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.speye(N);
%       nz = nonzeros(D)
%   end
%   
%   returns nz = codistributed.ones(N,1).
%   
%   t = issparse(D)
%   
%   returns t = true.
%   
%   See also NONZEROS, CODISTRIBUTED, CODISTRIBUTED/SPEYE.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/08/11 15:40:42 $

sDist = getCodistributor(S);
localS = getLocalPart(S);

if ~sDist.hNonzerosCheck()
    % The current codistributor doesn't support our nonzeros 
    % implementation.  We redistribute to a supported distribution 
    % scheme before proceeding.
    destCodistr = codistributor1d(ndims(S), ...
                                  codistributor1d.defaultPartition(size(S, ndims(S))), ...
                                  size(S));
    [localS, sDist] = distributedutil.Redistributor.redistribute(sDist, localS, destCodistr);
end

[LP, codistr] = sDist.hNonzerosImpl(localS);

nzs = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK>
