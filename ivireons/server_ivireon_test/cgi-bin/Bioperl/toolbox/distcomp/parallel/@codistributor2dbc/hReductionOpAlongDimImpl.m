function [LP, codistr] = hReductionOpAlongDimImpl(codistr, fcn, LP, dim) 
%hReductionOpAlongDimImpl Implementation for codistributor2dbc.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/07/14 03:53:45 $

if dim == 0 && distributedutil.Sizes.isSquareEmptyMatrix(codistr.Cached.GlobalSize)
    % For 0-by-0 empty codistributed array, we have to call fcn with only 1 input
    % argument because neither all(zeros(0, 0), 1) nor all(zeros(0, 0), 2)
    % is equivalent to all(zeros(0, 0)). 
    % If the global size is 0-by-0 then all the local parts are also 0-by-0.
    LP = fcn(LP);
    % At this point, LP is replicated, so we convert it into the actual 
    % local part.
    codistr = codistributor2dbc();
    srcLab = 0;  % All labs have the replicated array.
    [LP, codistr] = codistr.hBuildFromReplicatedImpl(srcLab, LP);
    return
end

if dim == 0
    dim = distributedutil.Sizes.firstNonSingletonDimension(codistr.Cached.GlobalSize);
end

% The reduction takes place in two stages.  Local reduction and a communicating
% reduction.  Look at a 2-by-2 lab grid to understand why:
% | 1 | 2 | 1 | 2 | 1 | 2 | ...
% | 3 | 4 | 3 | 4 | 3 | 4 | ...
% | 1 | 2 | 1 | 2 | 1 | 2 | ...
% | 3 | 4 | 3 | 4 | 3 | 4 | ...
% ...
%
% Assume the reduction is taking place along the rows.  By having all the labs
% reduce their local part along the reduction dimension, we end up with:
%
% | 1 | 2 | 1 | 2 | 1 | 2 | ...
% | 3 | 4 | 3 | 4 | 3 | 4 | ...

% 
% where each block is of size 1-by-BlockSize. 

% Local reduction step.
LP = fcn(LP, dim);

% Resolve cases that can be done without global communication.
if dim > 2
    % The reduction is complete and the global size hasn't changed, so
    % codistributor does not need to be modified.
    return;
end

orgSizeInDim = codistr.Cached.GlobalSize(dim);
gsize = codistr.Cached.GlobalSize;
% The resulting global size is 1 in the reduction dimension, unmodified in
% other dimensions.
gsize(dim) = 1;
codistr = codistributor2dbc(codistr.LabGrid, codistr.BlockSize, ...
                            codistr.Orientation, gsize);
if codistr.LabGrid(dim) == 1
    % Each row/column resides in its entirety on a single lab, and all labs are on
    % the edge of the lab grid.
    return;
elseif orgSizeInDim <= codistr.BlockSize
    LP = iHandleInteriorLabs(codistr, LP, dim);
else
    LP = iReduceAcrossLabs(codistr, fcn, LP, dim);
end

end % End of hReductionOpAlongDimImpl.

function LP = iReduceAcrossLabs(codistr, fcn, LP, dim)
% The input LP and codistr are the local part and codistributor after reducing
% along dim.  Handle the non-trivial case of reducing along the rows or the
% columns.
templateElement = LP;

% Concatenate all the reduced local parts along dimension dim, and store on the
% labs that are on the edge of the lab grid in the dim-th dimension.  In our
% example, this stores the results on labs 1 and 2.
LP = codistr.pCatToEdgeOfLabGrid(LP, dim);
if codistr.pIsOnLabGridEdge(dim);
    LP = fcn(LP, dim);
else
    % We pushed all the data to the edge of the lab grid, leaving us with an empty
    % local part of the appropriate size.  
    LP = distributedutil.Allocator.create(codistr.hLocalSize(), templateElement);
end

end % End of iReduceAcrossLabs

function LP = iHandleInteriorLabs(codistr, LP, dim)
% The input LP and codistr are the local part and codistributor after reducing
% along dim.  Handle the special case where the local part was non-trivial only
% on the edge of the lab grid, so we don't need to communicate to complete the
% reduction.
if ~codistr.pIsOnLabGridEdge(dim)
    LP = distributedutil.Allocator.create(codistr.hLocalSize(), LP);
end

end % End of iHandleInteriorLabs.
