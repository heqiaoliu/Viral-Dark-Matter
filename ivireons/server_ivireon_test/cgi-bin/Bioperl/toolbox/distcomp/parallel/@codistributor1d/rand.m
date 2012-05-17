function D = rand(varargin)
%RAND codistributed array of uniformly distributed pseudorandom numbers using codistributor
%   D = RAND(..., CODISTR) and D = RAND(..., CODISTR, ...) where CODISTR is a 1D
%   codistributor, are equivalent to calling CODISTRIBUTED.RAND with the same
%   input arguments.
%
%   Example:
%     Create a 1000-by-1000 codistributed array of pseudo-random numbers:
%     spmd
%         D = rand(1000, codistributor('1d'));
%     end
% 
%   See also RAND, CODISTRIBUTED/RAND, CODISTRIBUTOR1D


%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/04/15 22:59:49 $

try
    D = codistributed.rand(varargin{:});
catch E
    throw(E);
end

end % End of rand.
