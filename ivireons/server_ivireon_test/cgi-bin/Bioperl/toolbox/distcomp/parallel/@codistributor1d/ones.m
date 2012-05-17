function D = ones(varargin)
%ONES Ones codistributed array using codistributor
%   D = ONES(..., CODISTR) and D = ONES(..., CODISTR, ...) where CODISTR is a 1D
%   codistributor, are equivalent to calling CODISTRIBUTED.ONES with the same
%   input arguments.
%
%   Example:
%     Create a 1000-by-1000 codistributed array of ones:
%     spmd
%         D = ones(1000, codistributor('1d'));
%     end
% 
%   See also ONES, CODISTRIBUTED/ONES, CODISTRIBUTOR1D

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/04/15 22:59:46 $

try
    D = codistributed.ones(varargin{:});
catch E
    throw(E);
end

end % End of ones.
