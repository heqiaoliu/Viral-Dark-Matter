function D = randn(varargin)
%RANDN codistributed array of normally distributed pseudorandom numbers using codistributor
%   D = RANDN(..., CODISTR) and D = RANDN(..., CODISTR, ...) where CODISTR is a
%   1D codistributor, are equivalent to calling CODISTRIBUTED.RANDN with the
%   same input arguments.
%
%   Example:
%     Create a 1000-by-1000 codistributed array of pseudo-random numbers:
%     spmd
%         D = randn(1000, codistributor('1d'));
%     end
% 
%   See also RANDN, CODISTRIBUTED/RANDN, CODISTRIBUTOR1D

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/04/15 22:59:50 $

try
    D = codistributed.randn(varargin{:});
catch E
    throw(E);
end

end % End of randn.
