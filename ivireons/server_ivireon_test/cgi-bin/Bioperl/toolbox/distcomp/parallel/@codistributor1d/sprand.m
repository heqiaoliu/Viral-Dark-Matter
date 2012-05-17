function A = sprand(varargin)
%SPRAND Sparse uniformly distributed random codistributed matrix using codistributor
%   D = SPRAND(..., CODISTR) and D = SPRAND(..., CODISTR, ...) where CODISTR is a
%   1D codistributor, are equivalent to calling CODISTRIBUTED.SPRAND with the
%   same input arguments.
%
%   Example:
%     Create a 1000-by-1000 sparse uniformly distributed codistributed array:
%     spmd
%         D = sprand(1000, codistributor('1d'));
%     end
% 
%   See also SPRAND, CODISTRIBUTED/SPRAND, CODISTRIBUTOR1D

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/04/15 22:59:54 $

try
    A = codistributed.sprand(varargin{:});
catch E
    throw(E); % Strip off stack.
end

end % End of sprand.
