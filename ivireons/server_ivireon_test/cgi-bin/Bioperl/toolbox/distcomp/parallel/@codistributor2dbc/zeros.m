function D = zeros(varargin)
%ZEROS Zeros codistributed array using codistributor
%   D = ZEROS(..., CODISTR) and D = ZEROS(..., CODISTR, ...) where CODISTR is a
%   2D block-cyclic codistributor, are equivalent to calling CODISTRIBUTED.ZEROS
%   with the same input arguments.
%
%   Example:
%     Create a 1000-by-1000 codistributed array of logical 0:
%     spmd
%         D = zeros(1000, codistributor('2dbc'));
%     end
%
%   See also ZEROS, CODISTRIBUTED/ZEROS, CODISTRIBUTOR2DBC

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/15 23:00:31 $

try
    D = codistributed.zeros(varargin{:});
catch E
    throw(E);
end

end % End of zeros.
