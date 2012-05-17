function D = rand( varargin )
%DISTRIBUTED.RAND distributed array of uniformly distributed pseudorandom numbers
%   D = DISTRIBUTED.RAND(N) is an N-by-N distributed matrix of uniformly 
%   distributed pseudorandom numbers.
%   
%   D = DISTRIBUTED.RAND(M,N) is an M-by-N distributed matrix
%   of uniformly distributed pseudorandom numbers.
%   
%   D = DISTRIBUTED.RAND(M,N,P, ...) or DISTRIBUTED.RAND([M,N,P, ...])
%   is an M-by-N-by-P-by-... distributed array of uniformly distributed
%   pseudorandom numbers.
%   
%   D = DISTRIBUTED.RAND(M,N,P,..., CLASSNAME) or 
%   DISTRIBUTED.RAND([M,N,P,...], CLASSNAME) is an M-by-N-by-P-by-... 
%   distributed array of uniformly distributed pseudorandom numbers of class 
%   specified by CLASSNAME.
%   
%   Examples:
%       N  = 1000;
%       D1 = distributed.rand(N) % 1000-by-1000 distributed array of rand
%       D2 = distributed.rand(N, N*2) % 1000-by-2000
%       D3 = distributed.rand([N, N*2], 'single') % underlying class 'single'
%   
%   See also RAND, DISTRIBUTED, DISTRIBUTED/ZEROS, DISTRIBUTED/ONES.


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/03/25 22:01:56 $

% static method of distributed

D = distributed.sBuild( @codistributed.rand, 'rand', varargin{:} );
end
