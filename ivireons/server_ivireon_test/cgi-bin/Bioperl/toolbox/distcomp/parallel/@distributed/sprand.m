function D = sprand( varargin )
%DISTRIBUTED.SPRAND Sparse uniformly distributed random distributed matrix
%   D = DISTRIBUTED.SPRAND(M,N,DENSITY) is a random M-by-N sparse
%   distributed matrix with approximately DENSITY*M*N uniformly
%   distributed nonzero entries. 
%   
%   Example:
%       N = 1000;
%       D = distributed.sprand(N, N,0.01);
%   
%   See also SPRAND, DISTRIBUTED.
%   


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2009/04/15 23:01:44 $

% static method of distributed

D = distributed.sBuild( @codistributed.sprand, 'sprand', varargin{:} );

end
