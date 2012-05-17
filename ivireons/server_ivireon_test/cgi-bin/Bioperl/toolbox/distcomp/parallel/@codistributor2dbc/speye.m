function A = speye(varargin)
%SPEYE Overloaded to create a codistributed array
%   D = SPEYE(..., CODISTR) and D = SPEYE(..., CODISTR, ...) where CODISTR is a
%   2DBC codistributor, are equivalent to calling CODISTRIBUTED.SPEYE with the
%   same input arguments.
%
%   Example:
%     Create a 1000-by-1000 codistributed array sparse identity matrix.
%     spmd
%         D = speye(1000, codistributor('2dbc'));
%     end
% 
%   See also SPEYE, CODISTRIBUTED/SPEYE, CODISTRIBUTOR1D

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/08/29 08:23:30 $

try
    A = codistributed.speye(varargin{:});
catch E
    throw(E);
end
end % End of speye.
