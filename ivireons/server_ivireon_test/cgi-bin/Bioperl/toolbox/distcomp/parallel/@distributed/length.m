function l = length( D )
%LENGTH Length of distributed vector
%   L = LENGTH(D)
%   
%   Example:
%       N = 1000;
%       D = distributed.zeros(0,N,0);
%       l = length(D)
%   
%   returns l = 0.
%   
%   See also LENGTH, DISTRIBUTED, DISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/03/25 22:01:50 $

sz = size( D );
if min( sz ) == 0
    l = 0;
else
    l = max( sz );
end
end
