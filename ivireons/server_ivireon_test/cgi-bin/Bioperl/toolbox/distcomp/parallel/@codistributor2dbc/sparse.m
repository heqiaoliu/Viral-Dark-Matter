function A = sparse(varargin)
%SPARSE Create sparse codistributed matrix using codistributor
%   A = SPARSE(M,N,DIST) creates an M-by-N sparse codistributed array D of
%   underlying class DOUBLE whose codistributor is specified by DIST.
%
%   A = SPARSE(M,N,DIST, 'noCommunication') also creates an M-by-N sparse
%   codistributed array in the manner specified above, but does not perform any
%   global communication for error checking when constructing the array.
%
%   Example: 
%     spmd
%         A = sparse(1000, 1000, codistributor('2dbc'))
%     end
%
%   creates a 1000-by-1000 sparse codistributed double array A. 
%
%  See also: CODISTRIBUTED/SPARSE, CODISTRIBUTED/SPALLOC, CODISTRIBUTOR.

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/05/14 16:50:26 $

error(nargchk(3, 4, nargin, 'struct'));

try
    [m, n, codistr, allowCommunication] = distributedutil.CodistParser.parseCodistributorSparse(varargin);
    if allowCommunication
        argsToCheck = {m, n, codistr};
        distributedutil.CodistParser.verifyReplicatedInputArgs('sparse', argsToCheck);
    end
    nzmx = 0;
    A = codistributed.spalloc(m, n, nzmx, codistr, 'noCommunication');
catch E
    throw(E)
end

end % End of sparse.
