function [LPY, LPI, codistr] = hMinMaxImpl(codistr, fcnMinMax, LP, dim, wantI)
%hMinMaxImpl Implementation for codistributor2dbc.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/07/14 03:53:44 $
    
if ~(dim <= length(codistr.Cached.GlobalSize) && codistr.Cached.GlobalSize(dim) > 1)
    error('distcomp:codistributor2dbc:InvalidSize', ...
          'Dimension must be within bounds and size in dimension must be > 1.');
end
    
orgCodistr = codistr;
% Min and max on a non-empty array lead to size in dimension being 1.
gsize = codistr.Cached.GlobalSize;
gsize(dim) = 1;
% Construct local parts for the labs that now have empty local parts.
codistr = codistributor2dbc(codistr.LabGrid, ...
                            codistr.BlockSize, ...
                            codistr.Orientation, gsize);

if wantI
    [LPY, LPI] = fcnMinMax(LP, [], dim);
    globalInd = orgCodistr.globalIndices(dim);
    % The result of globalInd(LPI) has the same shape as globalInd, but we need
    % the result to be the same shape as LPI.
    LPI = reshape(globalInd(LPI), size(LPI));
else
    LPY = fcnMinMax(LP, [], dim);
    LPI = [];
end

if codistr.LabGrid(dim) == 1
    % Each row/column resides in its entirety on a single lab, and all labs are on
    % the edge of the lab grid.
    return;
elseif orgCodistr.Cached.GlobalSize(dim) <= codistr.BlockSize
    % We do not need to communicate because all the data already resides on the edge
    % of the lab grid.
    [LPY, LPI] = iHandleInteriorLabs(codistr, LPY, LPI, dim, wantI);
else
    [LPY, LPI] = iMinMaxAcrossLabs(codistr, fcnMinMax, LPY, LPI, dim, wantI);
end
end % End of hMinMaxImpl.

function [LPY, LPI] = iMinMaxAcrossLabs(codistr, fcnMinMax, LPY, LPI, dim, wantI)
% The input LPY and LPI are the data and the indices after calculating min/max
% on the local parts.
% We perform the second stage of min/max where we operate across the labs.
if wantI
    % Get LPY and LPI into a cell array so that we only communicate once.  Odd
    % entries store the Y's, even entries store the indices.    
    data = cat(dim, {LPY}, {LPI});
    data = codistr.pCatToEdgeOfLabGrid(data, dim);
    if codistr.pIsOnLabGridEdge(dim)
        firstData = cat(dim, data{1:2:end-1});
        firstInd = cat(dim, data{2:2:end});
        % We want the min/max operation to be stable.  I.e. if there are ties, we want
        % to pick the entry with the lowest global index in the dim-th
        % dimension.  We achieve this by re-arranging firstData and firstInd so
        % that the global indices are in ascending order in the dim-th
        % dimension.  
        [firstInd, rearrangement] = sort(firstInd, dim);
        linInd = distributedutil.IndexManip.sortIndToLinear(dim, rearrangement);
        firstData = firstData(linInd);
 
        % Perform the second stage min/max across all the local parts.
        [LPY, indToFirst] = fcnMinMax(firstData,[], dim); 
        linIndIntoFirst = distributedutil.IndexManip.minmaxIndToLinear(size(firstData), ...
                                                          dim, indToFirst);
        % Now firstData corresponds to firstInd, and LPY equals
        % firstData(linIndIntoFirst).  Therefore, Y corresponds to
        % firstInd(linIndIntoFirst).
        LPI = firstInd(linIndIntoFirst); 
    else
        % These labs don't store any data, so just allocate empty matrices of the
        % correct size and type.
        LPY = distributedutil.Allocator.create(codistr.hLocalSize(), LPY);
        LPI = distributedutil.Allocator.create(codistr.hLocalSize(), LPI);
    end
else
    data = codistr.pCatToEdgeOfLabGrid(LPY, dim);
    if codistr.pIsOnLabGridEdge(dim)
        LPY = fcnMinMax(data, [], dim); 
    else
        LPY = distributedutil.Allocator.create(codistr.hLocalSize(), LPY);
    end
    LPI = [];
end
end % End of iMinMaxAcrossLabs.

function [LPY, LPI] = iHandleInteriorLabs(codistr, LPY, LPI, dim, wantI)
% The input LP and codistr are the local part and codistributor after min/max
% along dim.  Handle the special case where the local part was non-trivial only
% on the edge of the lab grid, so we don't need to communicate to complete the
% min/max calculations.
if ~codistr.pIsOnLabGridEdge(dim)
    LPY = distributedutil.Allocator.create(codistr.hLocalSize(), LPY);
    if wantI
        LPI = distributedutil.Allocator.create(codistr.hLocalSize(), LPI);
    end
end
end % End of iHandleInteriorLabs.
