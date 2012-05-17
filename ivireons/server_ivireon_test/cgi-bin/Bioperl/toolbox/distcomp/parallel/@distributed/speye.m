function D = speye( varargin )
%DISTRIBUTED.SPEYE Sparse identity distributed matrix
%   D = DISTRIBUTED.SPEYE(N) is the N-by-N distributed matrix with ones on 
%   the  diagonal and zeros elsewhere.
%   
%   D = DISTRIBUTED.SPEYE(M,N) or DISTRIBUTED.SPEYE([M,N]) is the M-by-N 
%   distributed matrix with ones on the diagonal and zeros elsewhere.
%   
%   Example:
%       N = 1000;
%       D = distributed.speye(N);
%   
%   See also SPEYE, DISTRIBUTED.
%   


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $   $Date: 2009/04/15 23:01:42 $

% static method of distributed

D = distributed.sBuild( @codistributed.speye, 'speye', varargin{:} );

end
