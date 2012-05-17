function n = numel( obj, varargin )
%NUMEL Number of elements in distributed array or subscripted array expression
%   N = NUMEL(D) returns the number of underlying elements in the distributed 
%   array D.
%   
%   Example:
%       N = 1000;
%       D = distributed.ones(3,4,N);
%       ne = numel(D)
%   
%   returns ne = 12000.
%   
%   See also NUMEL, DISTRIBUTED.


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $   $Date: 2009/03/25 22:01:54 $

n = distributedutil.numelHelper(size(obj), varargin{:});
end
