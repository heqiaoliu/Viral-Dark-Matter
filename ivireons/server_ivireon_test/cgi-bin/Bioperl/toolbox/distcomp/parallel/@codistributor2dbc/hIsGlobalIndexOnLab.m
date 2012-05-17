function tf = hIsGlobalIndexOnLab(codistr, dim, gIndexInDim, lab)
%hIsGlobalIndexOnLab  Implementation for codistributor2dbc.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/18 15:50:42 $

if dim > 2
    tf = (gIndexInDim == 1);
    return;
end

% The trivial implementation of this function would be: tf =
% ismember(gIndexInDim, codistr.hGlobalIndicesImpl(dim, lab)) but that is much
% too slow.  Rather, we map lab to the processor row/column in the lab grid, and
% we map the indices in gIndexInDim to the processor row/column in the lab grid.
if dim == 1
    proc = codistr.pLabindexToProcessorRow(lab);
else
    proc = codistr.pLabindexToProcessorCol(lab);
end

% Use the block nature of 2DBC and map the global indices into the
% corresponding block.  For example, with a block size of 64, the global
% indices [1, 2, 3, 65, 129, 193, 257, 258] correspond to blocks [1, 1, 1,
% 2, 3, 4, 5, 5]
blocksInDim = floor((gIndexInDim - 1)/codistr.BlockSize) + 1;
% Use the cyclic nature of 2DBC and find the processor row/column that
% stores the blocks.  For example, if dim is 1 and LabGrid is [2, 3], then
% the blocks above correspond to procsInDim of [1, 1, 1, 2, 1, 2, 1, 1].
procsInDim = mod(blocksInDim - 1, codistr.LabGrid(dim)) + 1;
% The lab in question stores the global indices where the processor indices
% match.
tf = (procsInDim == proc);

end % End of hIsGlobalIndexOnLab.
