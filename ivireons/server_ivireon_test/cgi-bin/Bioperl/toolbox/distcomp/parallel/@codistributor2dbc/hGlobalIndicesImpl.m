function varargout = hGlobalIndicesImpl(dist, dim, lab)
%hGlobalIndicesImpl The implementation of global indices without the error checking.
%
%   See also codistributor2dbc/isComplete, codistributed/globalIndices.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/07/18 15:50:41 $

if dim > 2
    first = 1;
    last = 1;
    [varargout{1:nargout}] = convertToReturnArgs(first, last);
    return;
end

gsize = dist.Cached.GlobalSize();
blksize = dist.BlockSize;
lbgrid = dist.LabGrid;

% Calculate the (processRow, processCol) of the lab in the ScaLAPACK process
% grid.  
processRow = dist.pLabindexToProcessorRow(lab);
processCol = dist.pLabindexToProcessorCol(lab);

if dim == 1
    [first, last] = allGlobalIndices(processRow, lbgrid(1), blksize, gsize(1));
else
    [first, last] = allGlobalIndices(processCol, lbgrid(2), blksize, gsize(2));
end
[varargout{1:nargout}] = convertToReturnArgs(first,  last);

end % End of hGlobalIndicesImpl.


%------------
function [first, last] = allGlobalIndices(procID, numProcs, blksize, len)
%[first, last] = allGlobalIndices(process, numProcs, blksize, len) 
%       Calculate the global indices for process number procID out of numProcs.
%       The block size is blksize and the length in the dimension is len.
%       The global indices are returned as the start and the end indices.

% The number of blocks needed to cover all of this dimension.
numBlocks = ceil(len/blksize);

%Which lab row and column own last block.
procWithLastBlock = mod(numBlocks - 1, numProcs) + 1;

% Find the global indices for the lab's local part.
% The lab has the union of the indices first(i):last(i).
blocksOnLab = (procID:numProcs:numBlocks);
if isempty(blocksOnLab)
    first = 1;
    last = 0;
else
    first = blksize*(blocksOnLab - 1) + 1;
    last = first + (blksize - 1);
end

if procWithLastBlock == procID
    last(end) = len;
end
    
end % End of allGlobalIndices.

%------------
function varargout = convertToReturnArgs(first, last)
%Convert the input arguments into the correct output format for
%globalIndices.
if nargout == 2
    varargout{1} = first;
    varargout{2} = last;
    return;
end
% We return all the indices obtained by concatenating first(i):last(i).
% The total number of such indices is stored in len.
len = sum(diff([first; last]) + 1 );
ind = zeros(1, len);
offset = 1;
for i = 1:length(first)
    thisLen = last(i) - first(i) + 1;
    ind(offset: offset + thisLen - 1) = first(i):last(i);
    offset = offset + thisLen;
end
varargout{1} = ind;

end % End of convertToReturnArgs.
