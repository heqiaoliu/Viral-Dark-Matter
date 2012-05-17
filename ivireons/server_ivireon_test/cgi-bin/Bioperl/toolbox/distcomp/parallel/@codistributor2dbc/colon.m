function D = colon(varargin)
%COLON Build codistributed arrays of the form j:d:k using codistributor
%   V = COLON(..., CODISTR) and V = COLON(..., CODISTR, ...) where CODISTR is a
%   2D block-cyclic codistributor, are equivalent to calling CODISTRIBUTED.COLON
%   with the same input arguments.
%
%   Example:
%     Create the vector 1:1000 as a codistributed array:
%     spmd
%         v = colon(1, 1000, codistributor('2dbc'))
%     end
% 
%   See also COLON, CODISTRIBUTED/COLON, CODISTRIBUTOR2DBC

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/15 23:00:01 $

try
    D = codistributed.colon(varargin{:});
catch E
    throw(E);
end

end % End of colon.
