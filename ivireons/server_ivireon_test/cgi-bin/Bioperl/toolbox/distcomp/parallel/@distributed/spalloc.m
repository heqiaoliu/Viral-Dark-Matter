function D = spalloc( varargin )
%DISTRIBUTED.SPALLOC Allocate space for sparse distributed matrix
%   SD = DISTRIBUTED.SPALLOC(M,N,NZMAX) creates an M-by-N all-zero sparse 
%   distributed matrix with room to eventually hold NZMAX nonzeros.
%   
%   Example:
%       N = 1000;
%       SD = distributed.spalloc(N, N, 2*N);
%       for ii=1:N-1
%         SD(ii,ii:ii+1) = [ii ii];
%       end
%   
%   See also SPALLOC, DISTRIBUTED.
%   


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2009/04/15 23:01:41 $

% static method of distributed

D = distributed.sBuild( @codistributed.spalloc, 'spalloc', varargin{:} );

end
