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
%   If codistr is a complete codistributor1d object, 
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
%   In the specific case of codistributor1d objects, E and F are scalars,
%   and K = E:F.  The second argument is optional, and it defaults to
%   LABINDEX.
%
%   For codistributor1d objects, you can get a complete understanding of
%   which labs store which elements of a codistributed array by calling
%   globalIndices for the distribution dimension of the array.  The
%   codistributor must be complete before calling globalIndices.
%
%   Calling globalIndices on a codistributor object is equivalent to
%   calling it on the corresponding codistributed array.
%
%   Example: with numlabs = 4
%   spmd
%       siz = [128, 128];
%       codistr = codistributor1d(2, [], siz);
%       rowInd = codistr.globalIndices(1);
%       colInd = codistr.globalIndices(2);
%   end
%   will have rowInd equal to:
%       1:128 on all labs
%   and colInd will be equal to:
%       1:32 on lab 1
%       33:64 on lab 2
%       65:96 on lab 3
%       97:128 on lab 4
%
%   Example: Using globalIndices to load data from file and construct a
%   codistributed array distributed along the columns, i.e., dimension 2.
%   Notice how globalIndices makes the code not specific to the number of
%   labs and alleviates you from calculating offsets or partitions.
%
%   spmd
%       siz = [1000, 1000];
%       codistr = codistributor1d(2, [], siz);
%
%       % Use globalIndices to figure out which columns each lab should
%       % load.
%       [firstCol, lastCol] = codistr.globalIndices(2);
%
%       % Load all the values that should go into the local part for this
%       % lab.
%       localPart = readRectangleFromFile(fileName, ...
%                                         1, siz(1), firstCol, lastCol);
%
%       % With the local part and codistributor, we can construct
%       % the corresponding codistributed array.
%       D = codistributed.build(localPart, codistr);
%   end       
%
%   See also codistributor1d/isComplete, codistributed/globalIndices.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/07/18 15:50:36 $

error(nargchk(2, 3, nargin, 'struct'));
error(nargoutchk(0, 2, nargout, 'struct'));

if nargin < 3
    lab = labindex;
end

if ~dist.isComplete()
    error('distcomp:codistributord1d:globalIndicesImpInvalidInput', ...
          'Codistributor must be complete when obtaining global indices.');
end
AbstractCodistributor.pVerifyGlobalIndicesArgs(dim, lab);

[varargout{1:nargout}] = dist.hGlobalIndicesImpl(dim, lab);

end % End of globalIndices.
