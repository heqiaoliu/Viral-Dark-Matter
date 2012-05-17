function [LPY, LPI, codistr] = hMinMaxImpl(codistr, fcnMinMax, LP, dim, wantI)
; %#ok<NOSEM> % Undocumented
%hMinMaxImpl Implementation for codistributor1d.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/07/14 03:53:34 $

if ~(dim <= length(codistr.Cached.GlobalSize) && codistr.Cached.GlobalSize(dim) > 1)
    error('distcomp:codistributor1d:InvalidSize', ...
          'Dimension must be within bounds and size in dimension must be > 1.');
end

% First the labs independently calculate the min/max on their local part.
if wantI
    [LPY, LPI] = fcnMinMax(LP, [], dim);
else
    LPY = fcnMinMax(LP, [], dim);
    LPI = [];
end

if codistr.Dimension == dim
    % In general, we need to communicate for min/max across the distribution
    % dimension, but we try to find special cases where that is not necessary.
    if nnz(codistr.Partition) == 1
        [LPY, LPI, codistr] = iHandleTrivialPartition(codistr, LPY, LPI, wantI);
    else
        [LPY, LPI, codistr] = iMinMaxAcrossLabs(codistr, fcnMinMax, LPY, LPI, wantI);
    end
else
    % Operation was not along the distribution dimension, so output has
    % the same partition as the input.  However, we have reduced
    % the size in dim down to 1.
    gsize = codistr.Cached.GlobalSize;
    % Note that error checks at the top of the function guarantees that
    % length(gsize) >= dim, so we can assign to gsize(dim) and
    % gsize continues to be a valid size vector.
    gsize(dim) = 1;
    codistr = codistributor1d(codistr.Dimension, codistr.Partition, gsize);
end
    
end % End of hMinMaxImpl.

function [LPY, LPI, codistr] = iMinMaxAcrossLabs(codistr, fcnMinMax, LPY, LPI, wantI)
% The input LPY and LPI are the data and the indices after calculating min/max
% on the local parts.
% We perform the second stage of min/max where we operate across the labs.
if wantI
    % Convert LPI to be in terms of global indices along dimension rather
    % than as indices into the local part of the array.
    [start, ~] = codistr.globalIndices(codistr.Dimension, labindex); 
    LPI = LPI + start - 1; 
       
    % Gather all the local min/max and the indices from the first min/max
    % operation.  Pack the data into a cell array and then unpack so that
    % we only communicate once.
    % Opportunity for performance improvements by gcat-ing only to lab 1.
    data = gcat({LPY, LPI}, 2);
    repFirstData = cat(codistr.Dimension, data{1:2:end-1});
    repFirstInd = cat(codistr.Dimension, data{2:2:end});

    % Perform the second stage min/max across all the local parts.
    [repY, repIndToFirst] = fcnMinMax(repFirstData, [], codistr.Dimension);
    % Convert repIndToFirst into linear indices.
    linIndIntoFirst = distributedutil.IndexManip.minmaxIndToLinear(size(repFirstData), ...
                                                      codistr.Dimension, repIndToFirst);
    % Now repFirstData corresponds to repFirstInd, and repY equals
    % repFirstData(linIndIntoFirst).  Therefore, repY corresponds to
    % repFirstInd(linIndIntoFirst).
    repI = repFirstInd(linIndIntoFirst);
    
    % Construct local parts from the replicated data.
    % Size in codistr.Dimension is 1.  We should change this to use the last
    % non-singleton dimension instead.
    codistr = codistributor1d(codistr.Dimension);
    [LPY, codistr] = codistr.hBuildFromReplicatedImpl(0, repY);
    LPI = codistr.hBuildFromReplicatedImpl(0, repI);
else
    % Opportunity for performance improvements by gcat-ing only to lab 1.
    repFirstData = gcat(LPY, codistr.Dimension); % Gather local min/max
    repY = fcnMinMax(repFirstData, [], codistr.Dimension);    % Compute global min/max
    % Size in codistr.Dimension is 1.  We should change this to use the last
    % non-singleton dimension instead.
    codistr = codistributor1d(codistr.Dimension);
    [LPY, codistr] = codistr.hBuildFromReplicatedImpl(0, repY);
end
end % End of iMinMaxInDistDim.

function [LPY, LPI, codistr] = iHandleTrivialPartition(codistr, LPY, LPI, wantI)
% The input LPY and LPI are the data and the indices after calculating min/max
% on the local parts.
% We handle the special case where the min/max calculations can be completed
% without performing any communication because the entire array resides on a
% single lab.
if nnz(codistr.Partition) ~= 1
    error('distcomp:codistributor1d:MinMaxAlongDim:NonTrivialPartition', ...
          'Partition must be non-zero on exactly one lab.');
end

part = codistr.Partition;
part(part ~= 0) = 1;
gsize = codistr.Cached.GlobalSize;
% codistr.Dimension is guaranteed to be <= number of dimensions, so the
% following is valid:
gsize(codistr.Dimension) = 1;
codistr = codistributor1d(codistr.Dimension, part, gsize);
if codistr.Partition(labindex) == 0
    LPY = distributedutil.Allocator.create(codistr.hLocalSize(), LPY);
    if wantI
        LPI = distributedutil.Allocator.create(codistr.hLocalSize(), LPI);
    end
end

end % End of iHandleTrivialPartition.
