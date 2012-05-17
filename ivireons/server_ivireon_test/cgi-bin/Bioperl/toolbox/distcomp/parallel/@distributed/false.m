function D = false( varargin )
%DISTRIBUTED.FALSE False distributed array
%   D = DISTRIBUTED.FALSE(N) is an N-by-N distributed matrix 
%   of logical zeros.
%   
%   D = DISTRIBUTED.FALSE(M,N) is an M-by-N distributed matrix
%   of logical zeros.
%   
%   D = DISTRIBUTED.FALSE(M,N,P, ...) or DISTRIBUTED.FALSE([M,N,P, ...])
%   is an M-by-N-by-P-by-... distributed array of logical zeros.
%   
%   Example:
%       N  = 1000;
%       D1 = distributed.false(N) % 1000-by-1000 false distributed array
%       D2 = distributed.false(N, 2*N) % 1000-by-2000
%       D3 = distributed.false([N, 2*N]) % 1000-by-2000
%   
%   See also FALSE, DISTRIBUTED, DISTRIBUTED/TRUE, DISTRIBUTED/ZEROS.


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/03/25 22:01:40 $

% static method of distributed

D = distributed.sBuild( @codistributed.false, 'false', varargin{:} );
end
