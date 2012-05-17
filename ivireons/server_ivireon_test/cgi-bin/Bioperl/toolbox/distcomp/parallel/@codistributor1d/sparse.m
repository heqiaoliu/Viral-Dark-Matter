function A = sparse(varargin)
%SPARSE Create sparse codistributed matrix using codistributor
%   A = SPARSE(M,N,DIST) creates an M-by-N sparse codistributed array D of
%   underlying class DOUBLE whose codistributor is specified by DIST.
%
%   A = SPARSE(M,N,DIST, 'noCommunication') also creates an M-by-N sparse
%   codistributed array in the manner specified above, but does not perform any
%   global communication for error checking when constructing the array.
%
%   Construction Example: With numlabs=4
%     spmd
%         A = sparse(1000, 1000, codistributor())
%     end
%
%   creates a 1000-by-1000 sparse codistributed double array A. A is
%   codistributed by columns (dim = 2) and each lab contains a 1000-by-250
%   local piece of A.
%
%     spmd
%         A1 = logical(sparse(1000, 1000, codistributor('1d',1)))
%     end
%
%   creates a 1000-by-1000 sparse codistributed logical array A1. A1 is
%   distributed by rows (dim = 1) and each lab contains a 250-by-1000 local
%   piece of A1.
%
%     spmd
%         classUnderlying(A1)
%     end
%
%   returns 'logical'.
%
%  See also: CODISTRIBUTED/SPARSE, CODISTRIBUTED/SPALLOC, CODISTRIBUTOR.

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/05/14 16:50:22 $

error(nargchk(3, 4, nargin, 'struct'));

try
    [m, n, codistr, allowCommunication] = distributedutil.CodistParser.parseCodistributorSparse(varargin);
    if allowCommunication
        argsToCheck = {m, n, codistr};
        distributedutil.CodistParser.verifyReplicatedInputArgs('sparse', argsToCheck);
    end
    nzmx = 0;
    % We defer to hSpallocImpl to verify that the distribution dimension is <= 2.
    A = codistributed.spalloc(m, n, nzmx, codistr, 'noCommunication');
catch E
    throw(E); % Strip the stack off.
end

end % End of sparse.
