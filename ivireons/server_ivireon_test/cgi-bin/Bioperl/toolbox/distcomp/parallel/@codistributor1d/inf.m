function D = inf(varargin)
%INF Infinity codistributed array using codistributor
%   D = INF(..., CODISTR) and D = INF(..., CODISTR, ...) where CODISTR is a 1D
%   codistributor, are equivalent to calling CODISTRIBUTED.INF with the same
%   input arguments.
%
%   Example:
%     Create a 1000-by-1000 codistributed array of INFs:
%     spmd
%         D = inf(1000, codistributor('1d'));
%     end
% 
%   See also INF, CODISTRIBUTED/INF, CODISTRIBUTOR1D

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/04/15 22:59:43 $

try
    D = codistributed.inf(varargin{:});
catch E
    throw(E);
end

end % End of inf.
