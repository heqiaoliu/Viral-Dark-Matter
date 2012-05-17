function [LP, codistr] = hCell2MatImpl(codistr, LP)
; %#ok<NOSEM> % Undocumented
% Implementation of hCell2MatImpl for codistributor1d.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/10/12 17:28:13 $

if any(codistr.Cached.GlobalSize == 0)
    error('distcomp:codistributor1d:cell2mat:EmptyCellArray', ...
          'Cell array must not be empty.');
end

LP = distributedutil.syncOnError(@(x)cell2mat(x), LP);
% Even though the overall codistributed cell array was not empty, it is possible
% that the local part of the cell array was empty.  On those labs, LP is now an
% empty double array.  Thus, it is quite possible that the class and sparsity of
% LP is now inconsistent across the labs.

[szs, templ] = iGetSizesAndTemplates(LP, codistr);
emptyCellLocalPart = (codistr.Partition == 0);

% We have sufficient information to verify the consistency of the local parts
% across the labs without any communication.  Since the input cell array was not
% empty, we know that emptyCellLocalPart is false on some labs, and that on those
% labs, LP now stores some information that we need to process further.
templ = templ(~emptyCellLocalPart);
iVerifyTemplateConsistency(templ);

% When we verify the sizes, we deliberately ignore the local parts corresponding
% to empty local parts of the input cell array.
codistr = iGetCodistributorVerifyNonEmptySizes(codistr, szs);

% With the codistributor in hand, we can allocate the empty local parts.  Since
% we have ascertained that the template elements are consistent, we can pick any
% of them for the allocation.
if emptyCellLocalPart(labindex)
    LP = distributedutil.Allocator.create(codistr.hLocalSize(), templ{1});
end
end % End of hCell2MatImpl. 

function [szs, templ] = iGetSizesAndTemplates(LP, cellCodistr)
% Return a matrix of the size-contribution from the local parts on all labs, and
% a cell array of template elements.  We return a row of all zero sizes for a
% lab where the local part of the cell array is empty.  

emptyCellLocalPart = (cellCodistr.Partition == 0);
if emptyCellLocalPart(labindex)
    % Since the original local part was an empty cell array, we have no template
    % element to share with the other labs, so we provide a dummy template element.
    templ = {};
else
    templ = distributedutil.Allocator.extractTemplate(LP);
end
% Record the size of the local part after calling cell2mat on the local
% part of the cell array.
sz = size(LP);
% There are 3 possibilities to consider regarding the emptiness of the
% local parts:
%
% 1. The local part of the cell array was empty.  Such a local part doesn't
%    make any contribution to the output array.  Consequently, the
%    corresponding size must be recorded as [0, 0, ..., 0].
%
% 2. The local part of the cell array was non-empty, but it only contained
%    empties.  Such a local part contributes to the output array. Calling
%    cell2mat on such a local part returns [], which is of size [0, 0, 1,
%    1, ..., 1].
%
% 3. The local part of the cell array was nonempty, and it contained
%    non-empty arrays.  Calling cell2mat on the local part returns a
%    non-empty array, which is of size [m1, m2, ..., mn, 1, 1, ..., 1].
%
% We can distinguish case 1 from cases 2 and 3 by checking
% emptyCellLocalPart(labidx).  In cases 2 and 3, we may have to add the
% trailing 1's to the size vector.

data = {templ, sz};
data = gcat(data, 1);
szsCell = data(:, 2);
templ = data(:, 1);
% Represent all the non-empty sizes in a matrix with each row storing a size
% vector.  However, be careful because the sizes may not have the same length.
nDimsOfLP = max(cellfun(@length, szsCell));

% Get the sizes in all dimensions, up to and including the highest
% dimension we might care about.
nDims = max([length(cellCodistr.Cached.GlobalSize), ...
             cellCodistr.Dimension, ...
             nDimsOfLP]);
szs = zeros(numlabs, nDims);
for labidx = 1:numlabs
    currSz = szsCell{labidx};
    szs(labidx, 1:length(currSz)) = currSz;
    if ~emptyCellLocalPart(labidx)
        % Only fill in the trailing ones for the labs where the local part of
        % the cell array was not empty, as described in cases 2 and 3 above.
        szs(labidx, length(currSz)+1:end) = 1;
    end
end

end

function codistr = iGetCodistributorVerifyNonEmptySizes(cellCodistr, szs)
% Given the original codistributor and a matrix with sizes, get the resulting
% codistributor.  The sizes must be all zeros for labs that don't contribute
% anything to the resulting array.  The resulting array must not be empty.

% Assume for the moment that the sizes are consistent across the labs and
% calculate the resulting partition and global size.
% 
emptyCellLocalPart = (cellCodistr.Partition == 0);
% szs contains the contribution of each lab to the output of cell2mat, so the
% partition is given by the Dimension'th column.
part = szs(:, cellCodistr.Dimension)';
% Since we assume that the sizes are consistent, the global size in the
% non-distribution dimensions equals that of any of the non-empty local parts.
szs = szs(~emptyCellLocalPart, :);
gsize = szs(1, :);
gsize(cellCodistr.Dimension) = sum(part);

if size(szs, 1) > 1
    % More than one lab makes a non-trivial contribution to the resulting array, so
    % we need to verify that their contributions are indeed consistent.  Local
    % parts of output must have the same sizes in all dimensions other than the
    % distribution dimension on those labs.
    nonDistrSizes = szs(:, [1:cellCodistr.Dimension-1, cellCodistr.Dimension+1:end]);
    if ~all(all(bsxfun(@eq, nonDistrSizes, nonDistrSizes(1, :))))
         throwAsCaller(MException(...
             'distcomp:codistributed:cell2mat:InconsistentSizesOfLocalParts', ...
             'Dimensions of local parts are not consistent.'));
     end
end
codistr = codistributor1d(cellCodistr.Dimension, part, gsize);

end % End of iGetCodistributorVerifySizes.


function iVerifyTemplateConsistency(templ)
% Given a cell array of template elements for the non-empty local parts, verify
% that they are consistent with one another.

if length(templ) <= 1
    return;
end

allSameClass = cellfun('isclass', templ, class(templ{1}));
if ~allSameClass
    % Same error message as in base MATLAB.
    throwAsCaller(MException('distcomp:codistributed:cell2mat:MixedDataTypes', ...
          'All contents of the input cell array must be of the same data type.'));
end
if isstruct(templ{1})
    fields = cellfun(@fieldnames, templ, 'UniformOutput', false);
    if ~isequal(fields{:})
        % Same error message as in base MATLAB.
        throwAsCaller(MException(...
            'distcomp:codistributed:cell2mat:InconsistentFieldNames', ...
            ['The field names of each cell array element must be consistent ' ...
            'and in consistent order.']));
    end
end

end



