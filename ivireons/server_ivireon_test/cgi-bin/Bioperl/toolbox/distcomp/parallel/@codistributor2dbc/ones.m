function D = ones(varargin)
%ONES Ones codistributed array using codistributor
%   D = ONES(..., CODISTR) and D = ONES(..., CODISTR, ...) where CODISTR is a 2D
%   block-cyclic codistributor, are equivalent to calling CODISTRIBUTED.ONES
%   with the same input arguments.
%
%   Example:
%     Create a 1000-by-1000 codistributed array of ones:
%     spmd
%         D = ones(1000, codistributor('2dbc'));
%     end
% 
%   See also ONES, CODISTRIBUTED/ONES, CODISTRIBUTOR2DBC

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/15 23:00:19 $

try
    D = codistributed.ones(varargin{:});
catch E
    throw(E);
end

end % End of ones.
