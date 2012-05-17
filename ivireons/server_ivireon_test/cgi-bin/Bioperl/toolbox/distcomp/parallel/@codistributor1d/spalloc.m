function D = spalloc(varargin)
%SPALLOC Allocate space for sparse codistributed matrix using codistributor
%   D = SPALLOC(..., CODISTR) and D = SPALLOC(..., CODISTR, ...) where CODISTR
%   is a 1D codistributor, are equivalent to calling CODISTRIBUTED.SPALLOC with
%   the same input arguments.
%
%   Example:
%     Create a 1000-by-1000 codistributed sparse array with space
%     reserved for 100 non-zero elements:    
%     spmd
%         D = spalloc(1000, 1000, 100, codistributor('1d'));
%     end
% 
%   See also SPALLOC, CODISTRIBUTED/SPALLOC, CODISTRIBUTOR1D

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/15 22:59:51 $

try
    D = codistributed.spalloc(varargin{:});
catch E
    throw(E);
end

end % End of spalloc.
