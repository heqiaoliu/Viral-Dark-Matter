function D = sprandn( varargin )
%DISTRIBUTED.SPRANDN Sparse normally distributed random distributed matrix
%   D = DISTRIBUTED.SPRANDN(M,N,DENSITY) is a random M-by-N sparse
%   distributed matrix with approximately DENSITY*M*N normally
%   distributed nonzero entries. 
%   
%   Example:
%       N = 1000;
%       D = distributed.sprandn(N, N,0.01);
%   
%   See also SPRANDN, DISTRIBUTED.
%   


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2009/04/15 23:01:45 $

% static method of distributed

D = distributed.sBuild( @codistributed.sprandn, 'sprandn', varargin{:} );

end
