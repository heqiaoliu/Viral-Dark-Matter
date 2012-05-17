function A = sprand(varargin)
%SPRAND Sparse uniformly distributed random codistributed matrix using codistributor
%   D = SPRAND(..., CODISTR) and D = SPRAND(..., CODISTR, ...) where CODISTR is a
%   2DBC codistributor, are equivalent to calling CODISTRIBUTED.SPRAND with the
%   same input arguments.
%
%   Example:
%     Create a 1000-by-1000 sparse uniformly distributed codistributed array:
%     spmd
%         D = sprand(1000, codistributor('2dbc'));
%     end
% 
%   See also SPRAND, CODISTRIBUTED/SPRAND, CODISTRIBUTOR2DBC

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/15 23:00:28 $

try
    A = codistributed.sprand(varargin{:});
catch E
    throw(E); % Strip off stack.
end

end % End of sprand.
