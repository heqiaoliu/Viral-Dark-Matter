function D = true( varargin )
%DISTRIBUTED.TRUE True distributed array
%   D = DISTRIBUTED.TRUE(N) is an N-by-N distributed matrix 
%   of logical ones.
%   
%   D = DISTRIBUTED.TRUE(M,N) is an M-by-N distributed matrix
%   of logical ones.
%   
%   D = DISTRIBUTED.TRUE(M,N,P, ...) or DISTRIBUTED.TRUE([M,N,P, ...])
%   is an M-by-N-by-P-by-... distributed array of logical ones.
%   
%   Examples:
%       N  = 1000;
%       D1 = distributed.true(N) % 1000-by-1000 true logical distributed array
%       D2 = distributed.true(N, N*2) % 1000-by-2000
%       D3 = distributed.true([N, N*2]) % 1000-by-2000
%   
%   See also TRUE, DISTRIBUTED, DISTRIBUTED/FALSE, DISTRIBUTED/ONES.


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/03/25 22:02:02 $

% static method of distributed

D = distributed.sBuild( @codistributed.true, 'true', varargin{:} );
end
