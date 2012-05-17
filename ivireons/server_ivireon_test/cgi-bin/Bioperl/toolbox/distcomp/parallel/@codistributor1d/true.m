function D = true(varargin)
%TRUE True codistributed array using codistributor
%   D = TRUE(..., CODISTR) and D = TRUE(..., CODISTR, ...) where CODISTR is a 1D
%   codistributor, are equivalent to calling CODISTRIBUTED.TRUE with the same
%   input arguments.
%
%   Example:
%     Create a 1000-by-1000 codistributed array of logical 1:
%     spmd
%         D = true(1000, codistributor('1d'));
%     end
% 
%   See also TRUE, CODISTRIBUTED/TRUE, CODISTRIBUTOR1D

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/04/15 22:59:56 $

try
    D = codistributed.true(varargin{:});
catch E
    throw(E);
end

end % End of true.
