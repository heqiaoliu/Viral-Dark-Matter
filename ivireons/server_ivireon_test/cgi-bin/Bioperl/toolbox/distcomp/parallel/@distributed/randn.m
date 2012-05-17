function D = randn( varargin )
%DISTRIBUTED.RANDN distributed array of normally distributed pseudorandom numbers
%   D = DISTRIBUTED.RANDN(N) is an N-by-N distributed matrix of normally
%   distributed pseudorandom numbers.
%   
%   D = DISTRIBUTED.RANDN(M,N) is an M-by-N distributed matrix
%   of normally distributed pseudorandom numbers.
%   
%   D = DISTRIBUTED.RANDN(M,N,P, ...) or DISTRIBUTED.RANDN([M,N,P, ...])
%   is an M-by-N-by-P-by-... distributed array of normally distributed
%   pseudorandom numbers.
%   
%   D = DISTRIBUTED.RANDN(M,N,P,..., CLASSNAME) or 
%   DISTRIBUTED.RANDN([M,N,P,...], CLASSNAME) is an M-by-N-by-P-by-... 
%   distributed array of normally distributed pseudorandom numbers of class 
%   specified by CLASSNAME.
%   
%   Examples:
%       N  = 1000;
%       D1 = distributed.randn(N) % 1000-by-1000 distributed array of randn
%       D2 = distributed.randn(N, N*2) % 1000-by-2000
%       D3 = distributed.randn([N, N*2], 'single') % underlying class 'single'
%   
%   See also RANDN, DISTRIBUTED, DISTRIBUTED/ZEROS, DISTRIBUTED/ONES.


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/03/25 22:01:57 $

% static method of distributed

D = distributed.sBuild( @codistributed.randn, 'randn', varargin{:} );
end
