function D = cell(varargin)
%CELL Create codistributed cell array using codistributor
%   D = CELL(..., CODISTR) and D = CELL(..., CODISTR, ...) where CODISTR is a 1D
%   codistributor, are equivalent to calling CODISTRIBUTED.CELL with the same
%   input arguments.
%
%   Example:
%     Create a 1000-by-1000 codistributed cell array:
%     spmd
%         C = cell(1000, codistributor('1d'));
%     end
% 
%   See also CELL, CODISTRIBUTED/CELL, CODISTRIBUTOR1D

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/04/15 22:59:27 $

try
    D = codistributed.cell(varargin{:});
catch E
    throw(E);
end

end % End of cell.
