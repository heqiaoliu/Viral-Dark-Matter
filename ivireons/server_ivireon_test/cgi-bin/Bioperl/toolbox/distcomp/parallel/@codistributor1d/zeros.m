function D = zeros(varargin)
%ZEROS Zeros codistributed array using codistributor
%   D = ZEROS(..., CODISTR) and D = ZEROS(..., CODISTR, ...) where CODISTR is a
%   1D codistributor, are equivalent to calling CODISTRIBUTED.ZEROS with the
%   same input arguments.
%
%   Example:
%     Create a 1000-by-1000 codistributed array of zeros:
%     spmd
%         D = zeros(1000, codistributor('1d'));
%     end
% 
%   See also ZEROS, CODISTRIBUTED/ZEROS, CODISTRIBUTOR1D

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/04/15 22:59:57 $

try
    D = codistributed.zeros(varargin{:});
catch E
    throw(E);
end

end % End of zeros.
