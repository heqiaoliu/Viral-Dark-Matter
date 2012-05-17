function D = false(varargin)
%FALSE False codistributed array using codistributor
%   D = FALSE(..., CODISTR) and D = FALSE(..., CODISTR, ...) where CODISTR is a
%   2D block-cyclic codistributor, are equivalent to calling CODISTRIBUTED.FALSE
%   with the same input arguments.
%
%   Example:
%     Create a 1000-by-1000 codistributed array of logical 0:
%     spmd
%         D = false(1000, codistributor('2dbc'));
%     end
% 
%   See also FALSE, CODISTRIBUTED/FALSE, CODISTRIBUTOR2DBC

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/15 23:00:07 $

try
    D = codistributed.false(varargin{:});
catch E
    throw(E);
end

end % End of false.
