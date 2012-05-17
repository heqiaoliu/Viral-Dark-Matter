function A = eye(varargin)
%EYE Identity codistributed matrix using codistributor
%   D = EYE(..., CODISTR) and D = EYE(..., CODISTR, ...) where CODISTR is a
%   1D codistributor, are equivalent to calling CODISTRIBUTED.EYE with the
%   same input arguments.
%
%   Example:
%     Create a 1000-by-1000 codistributed array identity matrix.
%     spmd
%         D = eye(1000, codistributor('2dbc'));
%     end
% 
%   See also EYE, CODISTRIBUTED/EYE, CODISTRIBUTOR2DBC

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/15 23:00:06 $

try
    A = codistributed.eye(varargin{:});
catch E
    throw(E);
end
end % End of eye.
