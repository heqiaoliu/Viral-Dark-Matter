function n = numel( obj, varargin )
%NUMEL Number of elements in codistributed array or subscripted array expression
%   N = NUMEL(D) returns the number of underlying elements in the codistributed 
%   array D.
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(3,4,N);
%       ne = numel(D)
%   end
%   
%   returns ne = 12000.
%   
%   See also NUMEL, CODISTRIBUTED.


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2009/03/25 21:59:46 $

n = distributedutil.numelHelper(size(obj), varargin{:});
