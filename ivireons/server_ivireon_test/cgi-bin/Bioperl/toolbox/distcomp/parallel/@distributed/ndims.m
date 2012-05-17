function nd = ndims( obj )
%NDIMS Number of dimensions of distributed array
%   N = NDIMS(D)
%   
%   Example:
%       N = 1000;
%       D = distributed.rand(2,N,3);
%       n = ndims(D)
%   
%   returns n = 3.
%   
%   See also NDIMS, DISTRIBUTED, DISTRIBUTED/RAND.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2009/03/25 22:01:53 $

% Calculate number of dimensions directly from the full size vector
nd = length( obj.Size );
end
