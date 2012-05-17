function D = ones( varargin )
%DISTRIBUTED.ONES Ones distributed array
%   D = DISTRIBUTED.ONES(N) is an N-by-N distributed matrix of ones.
%   
%   D = DISTRIBUTED.ONES(M,N) is an M-by-N distributed matrix of ones.
%   
%   D = DISTRIBUTED.ONES(M,N,P,...) or DISTRIBUTED.ONES([M,N,P,...])
%   is an M-by-N-by-P-by-... distributed array of ones.
%   
%   D = DISTRIBUTED.ONES(M,N,P,..., CLASSNAME) or 
%   DISTRIBUTED.ONES([M,N,P,...], CLASSNAME) is an M-by-N-by-P-by-... 
%   distributed array of ones of class specified by CLASSNAME.
%   
%   Examples:
%       N  = 1000;
%       D1 = distributed.ones(N)   % 1000-by-1000 distributed matrix of ones
%       D2 = distributed.ones(N,N*2) % 1000-by-2000
%       D3 = distributed.ones([N,N*2], 'int8') % underlying class 'int8'
%   
%   See also ONES, DISTRIBUTED, DISTRIBUTED/ZEROS.
%   


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/03/25 22:01:55 $

% static method of distributed

D = distributed.sBuild( @codistributed.ones, 'ones', varargin{:} );
end
