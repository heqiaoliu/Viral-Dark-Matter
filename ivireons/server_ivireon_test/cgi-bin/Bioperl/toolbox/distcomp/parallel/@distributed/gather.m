function x = gather( obj )
%GATHER Retrieve contents of a distributed array to a single array on the client
%   X = GATHER(D) is a regular array formed from the contents
%   of the distributed array D.
%   
%   Example:
%   N = 1000;
%   D = distributed(magic(N));
%   M = gather(D);
%   
%   retrieves M = magic(N) on the client
%   
%   See also DISTRIBUTED.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/05/14 16:51:38 $

% Protect against broken distributed.
errorIfInvalid( obj );

% Generate the range structure - 1..size in each dimension
range =  struct( 'start', ones( ndims( obj ), 1 ), ...
                 'end', size( obj ).' );
% Use transferPortion to do the real work.
x = transferPortion( obj, range );
end
