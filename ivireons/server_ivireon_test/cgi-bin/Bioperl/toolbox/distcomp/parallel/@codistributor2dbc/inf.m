function D = inf(varargin)
%INF Infinity codistributed array using codistributor
%   D = INF(..., CODISTR) and D = INF(..., CODISTR, ...) where CODISTR is a 2D
%   block-cyclic codistributor, are equivalent to calling CODISTRIBUTED.INF with
%   the same input arguments.
%
%   Example:
%     Create a 1000-by-1000 codistributed array of INFs:
%     spmd
%         D = inf(1000, codistributor('2dbc'));
%     end
% 
%   See also INF, CODISTRIBUTED/INF, CODISTRIBUTOR2DBC

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/15 23:00:15 $

try
    D = codistributed.inf(varargin{:});
catch E
    throw(E);
end

end % End of inf.
