function [LP, codistr] = hNum2CellWithDimImpl(codistr, LP, dims)
; %#ok<NOSEM> % Undocumented
% Implementation of hNum2CellWithDimImpl for codistributor1d.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/09/23 13:59:29 $

% dims must be non-empty and only contain values in the range 1:numDims, and the
% global array must not be empty.

numDims = length(codistr.Cached.GlobalSize);
newSize = codistr.Cached.GlobalSize;
newSize(dims) = 1;
if all(newSize == 1) && codistr.Dimension <= numDims
    % The array is to be folded into a singleton, but it is currently distributed
    % between the labs.  We therefore gather onto a single lab and create a
    % codistributed scalar cell.
    targetLab = 1;
    LP = codistr.hGatherImpl(LP, targetLab);
    part = zeros(1, numlabs);
    part(targetLab) = 1;
    codistr = codistributor1d(2, part, [1, 1]);
    if labindex == targetLab
        LP = num2cell(LP, dims);
    else
        % Local part is an empty cell array.
        templ = {};
        LP = distributedutil.Allocator.create(codistr.hLocalSize(), templ);
    end
    return;
end
    
if any(dims == codistr.Dimension)
    % Redistribute over the dimension that will end up as the last unused
    % non-singleton dimension after the folding.  
    %
    % At this point, newSize(dims) equals 1, but newSize is not all 1's, so
    % newDim will not equal codistr.Dimension.
    newDim = distributedutil.Sizes.lastNonSingletonDimension(newSize);
    [LP, codistr] = distributedutil.Redistributor.redistribute(codistr, LP, codistributor1d(newDim));
end

% Since codistr.Dimension is not in dims, no communication is required and the
% output has the same distribution dimension and partition as the input.
sz = codistr.Cached.GlobalSize;
sz(dims) = 1;
codistr = codistributor1d(codistr.Dimension, codistr.Partition, sz);
if ~isempty(LP)
    LP = num2cell(LP, dims);
else
    % num2cell converts empties of all sizes into a 0-by-0 empty, so we
    % need to ensure that we return correct size of empty.
    LP = cell(codistr.hLocalSize());
end
end % End of hNum2CellWithDimImpl. 

