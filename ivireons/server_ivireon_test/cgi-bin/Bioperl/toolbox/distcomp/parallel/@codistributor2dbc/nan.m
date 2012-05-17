function D = nan(varargin)
%NAN Build codistributed array containing Not-a-Number using codistributor
%   D = NAN(..., CODISTR) and D = NAN(..., CODISTR, ...) where CODISTR is a 2D
%   block-cyclic codistributor, are equivalent to calling CODISTRIBUTED.NAN with
%   the same input arguments.
%
%   Example:
%     Create a 1000-by-1000 codistributed array of NaNs:
%     spmd
%         D = nan(1000, codistributor('2dbc'));
%     end
% 
%   See also NAN, CODISTRIBUTED/NAN, CODISTRIBUTOR2DBC

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/15 23:00:18 $

try
    D = codistributed.nan(varargin{:});
catch E
    throw(E);
end

end % End of nan.
