function D = eye( varargin )
%DISTRIBUTED.EYE Identity distributed matrix
%   D = DISTRIBUTED.EYE(N) is the N-by-N distributed matrix with ones on
%   the diagonal and zeros elsewhere.
%   
%   D = DISTRIBUTED.EYE(M,N) or DISTRIBUTED.EYE([M,N]) is the M-by-N 
%   distributed matrix with ones on the diagonal and zeros elsewhere.
%   
%   D = DISTRIBUTED.EYE() is the distributed scalar 1.
%   
%   D = DISTRIBUTED.EYE(M,N,CLASSNAME) or DISTRIBUTED.EYE([M,N],CLASSNAME)
%   is the M-by-N distributed identity matrix with underlying data of 
%   class CLASSNAME.
%   
%   Example:
%       N = 1000;
%       % Create a 1000-by-1000 distributed array with underlying class 'int32'.
%       D1 = distributed.eye(N,'int32');
%   
%   See also EYE, DISTRIBUTED.
%   


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $   $Date: 2009/05/14 16:51:37 $

% static method of distributed

D = distributed.sBuild( @codistributed.eye, 'eye', varargin{:} ); %#ok<DCUNK>
end
