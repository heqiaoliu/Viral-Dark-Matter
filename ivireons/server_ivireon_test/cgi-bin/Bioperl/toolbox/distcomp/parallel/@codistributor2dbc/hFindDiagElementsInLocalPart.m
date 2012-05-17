function localLinInd = hFindDiagElementsInLocalPart(codistr)
%hFindDiagElementsInLocalPart Return the local linear indices of the diagonal 
% elements of the local part for codistributor2dbc.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/22 03:42:31 $
    
% Look at the block grid for each lab, and find the blocks that are on the
% diagonal.  For example, with row orientation and a lab grid of [2,
% 3], the lab grid is laid out as:
% |  lab 1  |  lab 2 | lab 3 |
% |  lab 4  |  lab 5 | lab 6 |
%
% From that, we see that labs 1 and 5 store parts of the diagonal.  By
% repeating the grid a few times, we get a more complete picture of
% which blocks are on the diagonal.
%
% | 1 | 2 | 3 | 1 | 2 | 3 |   % 1 on the diagonal
% | 4 | 5 | 6 | 4 | 5 | 6 |   % 5 on the diagonal
% | 1 | 2 | 3 | 1 | 2 | 3 |   % 3 on the diagonal
% | 4 | 5 | 6 | 4 | 5 | 6 |   % 4 on the diagonal
% | 1 | 2 | 3 | 1 | 2 | 3 |   % 2 on the diagonal
% | 4 | 5 | 6 | 4 | 5 | 6 |   % 6 on the diagonal
% 
% Now, look at which of the blocks owned by lab 2 are on the diagonal.
% Lab 2 owns a total of 6 blocks in the picture, only one of which is
% on the diagonal:
%
% | no  | no  |
% | no  | no  |
% | no  | yes |
%
% In terms of the code below, we would say that for lab 2, blockRow =
% [3] and blockCol = [2], because that describes the single block it
% has on the diagonal.  Note that blockRow and blockCol are in terms of
% the blocks that lab 2 owns, and not in terms of all of the blocks
% that form the global matrix.

% Implement this in terms of global indices, so that we are independent of
% the grid orientation.
[rowStart, rowEnd] = codistr.globalIndices(1, labindex);
[colStart, colEnd] = codistr.globalIndices(2, labindex);
% Create nr-by-nc matrices of all the possible values of colStart and
% rowStart, and also calculate the block sizes.
nr = length(rowStart);
nc = length(colStart);
numColsInBlock = repmat(colEnd(:)' - colStart(:)' + 1, nr, 1);
numRowsInBlock = repmat(rowEnd(:) - rowStart(:) + 1, 1, nc);
colStart = repmat(colStart(:)', nr, 1);
rowStart = repmat(rowStart(:), 1, nc);

% All blocks are square, so the blocks that intersect with the diagonal
% have the upper left corner on the diagonal.
blockOnDiagonal = (colStart == rowStart);
% The diagonal in each block is bounded by both the number of columns and
% the number of rows in the block.
numElemsToUseInBlock = min(numRowsInBlock, numColsInBlock);

% Find which of the blocks owned by this lab are on the diagonal.
[blockRow, blockCol] = find(blockOnDiagonal);
numElemsToUseInBlock = numElemsToUseInBlock(blockOnDiagonal);

% Now that we know which block are on the diagonal, we can calculate the
% row and the column indices into the elements of that block.  Since
% our block information is in terms of blocks owned by this lab, the
% indices will be into the local part.
localRowStart = codistr.BlockSize*(blockRow - 1) + 1;
localRowEnd = localRowStart + numElemsToUseInBlock - 1;
localColStart = codistr.BlockSize*(blockCol - 1) + 1;
localColEnd = localColStart + numElemsToUseInBlock - 1;

% Get the union of localRowStart(i):localRowEnd(i) and the union of
% localColStart(i):localColEnd(i).  These must of course have the same
% number of elements in them.
numEl = sum(localRowEnd - localRowStart + 1);
localRowInd = zeros(1, numEl);
localColInd = zeros(1, numEl);
offset = 0;
for i = 1:length(localRowStart)
    currL = localRowEnd(i) - localRowStart(i) + 1;
    localRowInd(offset + 1:offset + currL) = localRowStart(i):localRowEnd(i);
    localColInd(offset + 1:offset + currL) = localColStart(i):localColEnd(i);
    offset = offset + currL;
end
% Finally, we need to implement the loop
% for i = 1:length(localRowInd)
%  LP(localRowInd(i), localColInd(i)) = 1;
% end
% But of course, we don't use a loop, but linear indices.
LPsize = codistr.hLocalSize();
localLinInd = sub2ind(LPsize, localRowInd, localColInd);
