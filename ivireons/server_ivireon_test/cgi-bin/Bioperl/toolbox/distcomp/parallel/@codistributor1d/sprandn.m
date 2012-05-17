function A = sprandn(varargin)
%SPRANDN Sparse normally distributed random codistributed matrix using codistributor
%   D = SPRANDN(..., CODISTR) and D = SPRANDN(..., CODISTR, ...) where CODISTR 
%   is a 1D codistributor, are equivalent to calling CODISTRIBUTED.SPRANDN with
%   the same input arguments.
%
%   Example:
%     Create a 1000-by-1000 sparse normally distributed codistributed array:
%     spmd
%         D = sprandn(1000, codistributor('1d'));
%     end
% 
%   See also SPRANDN, CODISTRIBUTED/SPRANDN, CODISTRIBUTOR1D

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.10.4 $  $Date: 2009/04/15 22:59:55 $

try
    A = codistributed.sprandn(varargin{:});
catch E
    throw(E); % Strip off stack.
end

end % End of sprandn.
