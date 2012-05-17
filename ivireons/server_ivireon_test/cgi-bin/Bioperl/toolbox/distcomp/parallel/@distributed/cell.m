function D = cell( varargin )
%DISTRIBUTED.CELL Create distributed cell array
%   D = DISTRIBUTED.CELL(N) is a distributed N-by-N cell array of
%   empty matrices.
%   
%   D = DISTRIBUTED.CELL(M,N) or D = DISTRIBUTED.CELL([M,N]) is a
%   distributed M-by-N cell array of empty matrices.
%   
%   D = DISTRIBUTED.CELL(M,N,P, ...) or DISTRIBUTED.CELL([M,N,P, ...])
%   is an M-by-N-by-P-by-... distributed cell array of empty matrices.
%   
%   Examples:
%       N  = 1000;
%       % Create a 1000-by-1000 distributed cell array.
%       D1 = distributed.cell(N) 
%   
%   See also CELL, DISTRIBUTED, DISTRIBUTED/ZEROS, DISTRIBUTED/ONES.


%   Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2009/03/25 22:01:33 $

% static method of distributed

D = distributed.sBuild( @codistributed.cell, 'cell', varargin{:} );
end
