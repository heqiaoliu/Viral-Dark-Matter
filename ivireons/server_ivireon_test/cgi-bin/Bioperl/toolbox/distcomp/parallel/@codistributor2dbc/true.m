function D = true(varargin)
%TRUE True codistributed array using codistributor
%   D = TRUE(..., CODISTR) and D = TRUE(..., CODISTR, ...) where CODISTR is a 2D
%   block-cyclic codistributor, are equivalent to calling CODISTRIBUTED.TRUE
%   with the same input arguments.
%
%   Example:
%     Create a 1000-by-1000 codistributed array of logical 1:
%     spmd
%         D = true(1000, codistributor('2dbc'));
%     end
% 
%   See also TRUE, CODISTRIBUTED/TRUE, CODISTRIBUTOR2DBC

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/15 23:00:30 $

try
    D = codistributed.true(varargin{:});
catch E
    throw(E);
end

end % End of true.
