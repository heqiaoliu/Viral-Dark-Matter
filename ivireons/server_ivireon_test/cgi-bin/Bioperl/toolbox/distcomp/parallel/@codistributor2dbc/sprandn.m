function A = sprandn(varargin)
%SPRANDN Sparse normally distributed random codistributed matrix using codistributor
%   D = SPRANDN(..., CODISTR) and D = SPRANDN(..., CODISTR, ...) where CODISTR 
%   is a 2DBC codistributor, are equivalent to calling CODISTRIBUTED.SPRANDN with
%   the same input arguments.
%
%   Example:
%     Create a 1000-by-1000 sparse normally distributed codistributed array:
%     spmd
%         D = sprandn(1000, codistributor('2dbc'));
%     end
% 
%   See also SPRANDN, CODISTRIBUTED/SPRANDN, CODISTRIBUTOR2DBC

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/15 23:00:29 $

try
    A = codistributed.sprandn(varargin{:});
catch E
    throw(E); % Strip off stack.
end

end % End of sprandn.
