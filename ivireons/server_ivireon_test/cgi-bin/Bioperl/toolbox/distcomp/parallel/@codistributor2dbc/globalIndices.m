function varargout = globalIndices(dist, dim, lab)
%globalIndices Global indices for the local part corresponding to codistributor
%   Global indices tell you the relationship between indices on a local
%   part and the corresponding indices on the distributed array.  The
%   global indices method on a codistributor object allows you to get this
%   relationship without actually creating the array.
%
%   A single call to globalIndices returns information about a single
%   dimension of the distributed array. In general, it is necessary to
%   consider the intersection of the results of calling globalIndices for
%   all array dimensions to discover which elements a specified lab stores.
%
%   If codistr is a complete codistributor2dbc object, 
%   K = codistr.globalIndices(DIM, LAB)
%   returns a vector K such that the corresponding local part on the
%   specified lab stores information about some or all of the elements with
%   index K in the DIM-th dimension.  The second argument is optional, and
%   it defaults to LABINDEX.
%
%   In general for codistributor objects, 
%   [E,F] = codistr.globalIndices(DIM, LAB)
%   returns two vectors E and F such that the corresponding local part on
%   the specified lab stores information about some or all of the element
%   with indices [E(1):F(1), ..., E(end):F(end)] in the DIM-th dimension.
%   The second argument is optional, and it defaults to LABINDEX.
%
%   For codistributor2dbc objects, it is necessary to call globalIndices
%   for both the 1st and 2nd dimension to be able to deduce which elements
%   reside on which lab.  The codistributor must be complete before calling
%   globalIndices.
%
%   Calling globalIndices on a codistributor object is equivalent to
%   calling it on the corresponding codistributed array.
%
%   Example: with numlabs = 4
%   spmd
%       siz = [128, 128];
%       codistr = codistributor2dbc([2, 2], 64, 'row', siz);
%       rowInd = codistr.globalIndices(1);
%       colInd = codistr.globalIndices(2);
%   end
%   will have rowInd equal to:
%       1:64 on labs 1 and 2 
%       65:128 on labs 3 and 4
%   and colInd will be equal to:
%       1:64 on labs 1 and 3
%       65:128 on labs 2 and 4
%
%   Example: Use globalIndices to load data from file and construct a
%   codistributed array using the 2D block cyclic distribution.  Notice how
%   globalIndices makes the code not specific to the number of labs and
%   alleviates you from calculating offsets or partitions.
%
%   spmd
%       siz = [1000, 1000];
%       labGrid = codistributor2dbc.defaultLabGrid;
%       blockSize = codistributor2dbc.defaultBlockSize;
%       orient = codistributor2dbc.defaultOrientation;
%       codistr = codistributor2dbc(labGrid, blockSize, orient, siz);
%
%       % Use globalIndices to figure out which rows and columns each lab
%       % should load.
%       [firstRow, lastRow] = codistr.globalIndices(1);
%       [firstCol, lastCol] = codistr.globalIndices(2);
%       
%       % Now loop over all permissible i and j values and load all the
%       % blocks in the local part of the 2D block-cyclic array.
%       for i = 1:length(firstRow)
%           for j = 1:length(firstCol)
%              blocks{i,j} = readRectangleFromFile(fileName, ...
%                                              firstRow(i), lastRow(i), ...
%                                              firstCol(j), lastCol(j));
%          end
%       end
%
%       % Combine the individual blocks into the single array which is the
%       % local part.  With the local part and codistributor, we can
%       % construct the codistributed array.
% 
%       localPart = cell2mat(blocks);
%       D = codistributed.build(localPart, codistr);
%   end       
%
%   See also codistributor2dbc/isComplete, codistributed/globalIndices.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/07/18 15:50:40 $

error(nargchk(2, 3, nargin, 'struct'));
error(nargoutchk(0, 2, nargout, 'struct'));

if nargin < 3
    lab = labindex;
end

if ~dist.isComplete()
    error('distcomp:codistributor2dbc:globalIndicesNotComplete', ...
          'Codistributor must be complete when obtaining global indices.');
end
AbstractCodistributor.pVerifyGlobalIndicesArgs(dim, lab);

[varargout{1:nargout}] = dist.hGlobalIndicesImpl(dim, lab);

end % End of globalIndices.
