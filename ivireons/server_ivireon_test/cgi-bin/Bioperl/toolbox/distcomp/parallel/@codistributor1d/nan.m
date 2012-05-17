function D = nan(varargin)
%NAN Build codistributed array containing Not-a-Number using codistributor
%   D = NAN(..., CODISTR) and D = NAN(..., CODISTR, ...) where CODISTR is a 1D
%   codistributor, are equivalent to calling CODISTRIBUTED.NAN with the same
%   input arguments.
%
%   Example:
%     Create a 1000-by-1000 codistributed array of NaNs:
%     spmd
%         D = nan(1000, codistributor('1d'));
%     end
% 
%   See also NAN, CODISTRIBUTED/NAN, CODISTRIBUTOR1D

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/04/15 22:59:45 $

try
    D = codistributed.nan(varargin{:});
catch E
    throw(E);
end

end % End of nan.
