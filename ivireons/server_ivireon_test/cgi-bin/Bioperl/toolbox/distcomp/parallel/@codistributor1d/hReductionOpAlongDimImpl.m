function [LP, codistr] = hReductionOpAlongDimImpl(codistr, fcn, LP, dim)
; %#ok<NOSEM> % Undocumented
%hReductionOpAlongDimImpl Implementation for codistributor1d.

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/07/14 03:53:35 $

dDim = codistr.Dimension;
if dim == 0 && distributedutil.Sizes.isSquareEmptyMatrix(codistr.Cached.GlobalSize)
    % For 0-by-0 empty codistributed array, we have to call fcn with only 1 input
    % argument because neither all(zeros(0, 0), 1) nor all(zeros(0, 0), 2)
    % is equivalent to all(zeros(0, 0)). 
    %
    % We have to be careful in that when the global size is 0-by-0, numlabs > 1
    % and dDim > 2, then the local part is of size 0-by-0-by-1-by-1...1-by-0 on
    % the labs where the partition is 0 and it is of size 0-by-0 on the lab
    % where the partition is 1.  In order to avoid all of those problems, we
    % replace the local part with the 0-by-0 replicated array that represents
    % the global array.  All labs can then perform the same reduction operation.
    LP = fcn(distributedutil.Allocator.create([0, 0], LP));
    codistr = codistributor('1d', dDim);
    % All labs have the replicated array with the result of the reduction operation.
    % Construct the resulting codistributed array from the replicated.
    srcLab = 0;  
    [LP, codistr] = codistr.hBuildFromReplicatedImpl(srcLab, LP);
    return
end

if dim == 0
    dim = distributedutil.Sizes.firstNonSingletonDimension(codistr.Cached.GlobalSize);
end

LP = fcn(LP,dim);

if dDim == dim
    % In general, we need to communicate for reductions across the distribution
    % dimension, but we try to find special cases where that is not
    % necessary.
    if nnz(codistr.Partition) <= 1
        [LP, codistr] = iHandleTrivialPartition(codistr, LP);
    else
        [LP, codistr] = iReduceAcrossLabs(codistr, fcn, LP);
    end
else
    % Operation was not along the distribution dimension, so output has same
    % partition as input.  However, we have reduced or increased the size
    % in dim to 1.
    gsize = codistr.Cached.GlobalSize;
    % Ensure that the global size is correct even if dim > length(gsize).
    gsize(end + 1: dim - 1) = 1;
    gsize(dim) = 1;
    codistr = codistributor1d(dDim, codistr.Partition, gsize);
end

end % End of hReductionOpAlongDimImpl.

function [LP, codistr] = iReduceAcrossLabs(codistr, fcn, LP)
% The input LP is the local part after reducing along codistr.Dimension.
% We have yet to reduce LP across the labs along codistr.Dimension.

replicatedD = gcat(LP, codistr.Dimension);
replicatedD = fcn(replicatedD, codistr.Dimension);
% At this point, LP is replicated, so we convert it into the actual 
% local part.
%% TODO: Use the last non-singleton dimension, not this trivial dimension.
codistr = codistributor1d(codistr.Dimension);
[LP, codistr] = codistr.hBuildFromReplicatedImpl(0, replicatedD);

end % End of iReduceAcrossLabs.

function [LP, codistr] = iHandleTrivialPartition(codistr, LP)
% The input LP is the local part after reducing along codistr.Dimension.
% We handle the special case where the reduction can be completed without
% performing any communication because the entire array resides on a single
% lab.

switch nnz(codistr.Partition)
  case 0
    % Local part started as a replicated empty, and LP is now a replicated
    % array.  Global size in distribution dimension was 0, is now 1.
    codistr = codistributor1d(codistr.Dimension);
    [LP, codistr] = codistr.hBuildFromReplicatedImpl(0, LP);
  case 1
    % The local part was non-trivial on a single lab.  The labs that had empty
    % local part a new local part of the correct size and type.
    part = codistr.Partition;
    part(part ~= 0) = 1;
    gsize = codistr.Cached.GlobalSize;
    gsize(end+1:codistr.Dimension-1) = 1;
    gsize(codistr.Dimension) = 1;
    codistr = codistributor1d(codistr.Dimension, part, gsize);
    if codistr.Partition(labindex) == 0
        LP = distributedutil.Allocator.create(codistr.hLocalSize(), LP);
    end
  otherwise
    error('distcomp:codistributor1d:ReductionAlongDim:InvalidPartition', ...
          'Partition must be non-zero on at most one lab.');
end

end % End of iHandleTrivialPartition.
