function D = inf( varargin )
%DISTRIBUTED.INF Infinity distributed array
%   D = DISTRIBUTED.INF(N) is an N-by-N distributed matrix of INFs.
%   
%   D = DISTRIBUTED.INF(M,N) is an M-by-N distributed matrix of INFs.
%   
%   D = DISTRIBUTED.INF(M,N,P,...) or DISTRIBUTED.INF([M,N,P,...])
%   is an M-by-N-by-P-by-... distributed array of INFs.
%   
%   D = DISTRIBUTED.INF(M,N,P,..., CLASSNAME) or 
%   DISTRIBUTED.INF([M,N,P,...], CLASSNAME) is an M-by-N-by-P-by-... 
%   distributed array of INFs of class specified by CLASSNAME.  CLASSNAME 
%   must be either 'single' or 'double'.
%   
%   As shown in the example, all forms of the built-in function have been 
%   overloaded for distributed arrays.
%   
%   Example:
%   % Create a 1000-by-1 distributed array of underlying class 'single' 
%   % containing the value Inf:
%       N = 1000;
%       D1 = distributed.inf(N, 1,'single')
%       D2 = distributed.Inf(1, N)
%   
%   See also INF, DISTRIBUTED, DISTRIBUTED/ZEROS, DISTRIBUTED/ONES.


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/03/25 22:01:46 $

% static method of distributed

D = distributed.sBuild( @codistributed.inf, 'inf', varargin{:} );
end
