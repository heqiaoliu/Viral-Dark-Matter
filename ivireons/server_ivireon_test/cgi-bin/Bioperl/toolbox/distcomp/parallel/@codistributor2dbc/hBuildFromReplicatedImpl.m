function [LP, codistr] = hBuildFromReplicatedImpl(codistr, srcLab, X)
; %#ok<NOSEM> % Undocumented
% Implementation of method for codistributor2dbc.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/15 23:00:09 $

sizeX = size(X);
supported = distributedutil.Allocator.supportsCreation(X);
classX = class(X);

if srcLab ~= 0
    % All labs other than srcLab need to know what the size of X is and whether we
    % support its use.  Broadcast both in one go to minimize collective
    % communication.
    data = labBroadcast(srcLab, {size(X), supported, classX});
    [sizeX, supported, classX] = deal(data{:});
end

if ~supported
    error('distcomp:codistributor2dbc:BuildFromReplicated:UnsupportedClass',...
          ['Class %s is not supported as the underlying class for ' ...
           'codistributed arrays.'], classX);
end

ndims = length(sizeX);
if ndims > 2
    error('distcomp:codistributed2dbc:UnsupportedNDim', ...
          ['The 2D block-cyclic distribution scheme only supports matrices.  '...
           'The provided array had %d dimensions.'], ndims);
end

% We need to work with a completely specified codistributor with the correct
% global size.
codistr = codistr.hGetCompleteForSize(sizeX);

if srcLab == 0
    rowInd = codistr.globalIndices(1, labindex);
    colInd = codistr.globalIndices(2, labindex);
    LP = X(rowInd, colInd);
    return;
end

% Have srcLab send the appropriate portions to the other labs.
mwTag = 31683; 
if labindex == srcLab
    for destLab = 1:numlabs
        if destLab ~= srcLab
            rowInd = codistr.globalIndices(1, destLab);
            colInd = codistr.globalIndices(2, destLab);
            labSend(X(rowInd, colInd), destLab, mwTag);
        end
    end
    % Retain the portion that corresponds to our local part.
    rowInd = codistr.globalIndices(1, labindex);
    colInd = codistr.globalIndices(2, labindex);
    LP = X(rowInd, colInd);
else
    LP = labReceive(srcLab, mwTag);
end

end % End of hBuildFromReplicatedImpl.
