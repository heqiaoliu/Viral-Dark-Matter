function D = colon(varargin)
%COLON Build codistributed arrays of the form j:d:k using codistributor
%   V = COLON(..., CODISTR) and V = COLON(..., CODISTR, ...) where CODISTR is a
%   1D codistributor, are equivalent to calling CODISTRIBUTED.COLON with the
%   same input arguments.
%
%   Example:
%     Create the vector 1:1000 as a codistributed array:
%     spmd
%         v = colon(1, 1000, codistributor('1d'))
%     end
% 
%   See also COLON, CODISTRIBUTED/COLON, CODISTRIBUTOR1D

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/15 22:59:29 $

try
    D = codistributed.colon(varargin{:});
catch E
    throw(E);
end

end % End of rand.
