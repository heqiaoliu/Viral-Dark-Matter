function D = randn(varargin)
%RANDN codistributed array of normally distributed pseudorandom numbers using codistributor
%   D = RANDN(..., CODISTR) and D = RANDN(..., CODISTR, ...) where CODISTR is a
%   2D block-cyclic codistributor, are equivalent to calling CODISTRIBUTED.RANDN
%   with the same input arguments.
%
%   Example:
%     Create a 1000-by-1000 codistributed array of pseudo-random numbers:
%     spmd
%         D = randn(1000, codistributor('2dbc'));
%     end
% 
%   See also RANDN, CODISTRIBUTED/RANDN, CODISTRIBUTOR2DBC

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/15 23:00:23 $

try
    D = codistributed.randn(varargin{:});
catch E
    throw(E);
end

end % End of randn.
