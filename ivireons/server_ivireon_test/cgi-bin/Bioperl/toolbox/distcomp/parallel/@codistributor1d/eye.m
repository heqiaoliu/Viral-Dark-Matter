function A = eye(varargin)
%EYE Identity codistributed matrix using codistributor
%   D = EYE(..., CODISTR) and D = EYE(..., CODISTR, ...) where CODISTR is a
%   1D codistributor, are equivalent to calling CODISTRIBUTED.EYE with the
%   same input arguments.
%
%   Example:
%     Create a 1000-by-1000 codistributed array identity matrix.
%     spmd
%         D = eye(1000, codistributor('1d'));
%     end
% 
%   See also EYE, CODISTRIBUTED/EYE, CODISTRIBUTOR1D

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/04/15 22:59:36 $

try
    A = codistributed.eye(varargin{:});
catch E
    throw(E);
end
end % End of eye.
