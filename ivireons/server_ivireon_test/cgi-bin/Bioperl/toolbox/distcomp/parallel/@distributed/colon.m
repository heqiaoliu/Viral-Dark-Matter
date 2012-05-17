function D = colon( varargin )
%DISTRIBUTED.COLON Build distributed arrays of the form A:D:B
%   DISTRIBUTED.COLON returns a distributed vector equivalent to the return 
%   vector of the COLON function or the colon notation. 
%   
%   D = DISTRIBUTED.COLON(A,B) is the same as DISTRIBUTED.COLON(A,1,B).
%   
%   D = DISTRIBUTED.COLON(A,D,B) is a distributed vector storing the values
%   A:D:B.
%   
%   Example:
%       N = 1000;
%       d = distributed.colon(1,N)
%   
%   distributes the vector 1:N over the labs.
%   
%   See also COLON, DISTRIBUTED.


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2009/03/25 22:01:36 $

% static method of distributed

D = distributed.sBuild( @codistributed.colon, 'colon', varargin{:} );
end
