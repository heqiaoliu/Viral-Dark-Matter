function D = zeros( varargin )
%DISTRIBUTED.ZEROS Zeros distributed array
%   D = DISTRIBUTED.ZEROS(N) is an N-by-N distributed matrix of zeros.
%   
%   D = DISTRIBUTED.ZEROS(M,N) is an M-by-N distributed matrix of zeros.
%   
%   D = DISTRIBUTED.ZEROS(M,N,P,...) or DISTRIBUTED.ZEROS([M,N,P,...])
%   is an M-by-N-by-P-by-... distributed array of zeros.
%   
%   D = DISTRIBUTED.ZEROS(M,N,P,..., CLASSNAME) or 
%   DISTRIBUTED.ZEROS([M,N,P,...], CLASSNAME) is an M-by-N-by-P-by-... 
%   distributed array of zeros of class specified by CLASSNAME.
%   
%   Examples:
%       N  = 1000;
%       D1 = distributed.zeros(N)   % 1000-by-1000 distributed matrix of zeros
%       D2 = distributed.zeros(N,N*2) % 1000-by-2000
%       D3 = distributed.zeros([N,N*2], 'int8') % underlying class 'int8'
%   
%   See also ZEROS, DISTRIBUTED, DISTRIBUTED/ONES.


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/03/25 22:02:03 $

% static method of distributed

D = distributed.sBuild( @codistributed.zeros, 'zeros', varargin{:} );
end
