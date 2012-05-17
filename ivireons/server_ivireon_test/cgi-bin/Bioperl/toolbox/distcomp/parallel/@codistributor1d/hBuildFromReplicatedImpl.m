function [LP, codistr] = hBuildFromReplicatedImpl(codistr, srcLab, X)
; %#ok<NOSEM> % Undocumented
  % Implementation of hBuildFromReplicatedImpl for codistributor1d.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/08/29 08:23:21 $
    
sizeX = size(X);
isXsparse = issparse(X);
supported = distributedutil.Allocator.supportsCreation(X);
classX = class(X);

if srcLab ~= 0
    % All labs other than srcLab need to know what the size of X is and whether we
    % support its use.  Broadcast both in one go to minimize collective
    % communication.
    data = labBroadcast(srcLab, {size(X), isXsparse, supported, classX});
    [sizeX, isXsparse, supported, classX] = deal(data{:});
end

if ~supported
    error('distcomp:codistributor1d:BuildFromReplicated:UnsupportedClass',...
          ['Class %s is not supported as the underlying class for ' ...
           'codistributed arrays.'], classX);
end

% We need to work with a completely specified codistributor with the correct
% global size.
codistr = codistr.hGetCompleteForSize(sizeX);

if isXsparse 
    codistr.hVerifySupportsSparse();
end

% Extract or send/receive the appropriate local part.
LP = getLocalPart(X, srcLab, codistr);

end % End of hBuildFromReplicatedImpl.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function X = getLocalPart(X, srcLab, codistr)
%LP = getLocalPart(X, srcLab, codistr)  Go from a full array to the local parts.

szX = codistr.Cached.GlobalSize;
% Pad size of X with trailing ones if dim > ndims(X).  This allows us to create
% the right substruct for the subsref that follows.
if codistr.Dimension > length(szX)
    szX(end+1:codistr.Dimension) = 1;
end

idx = substruct('()', repmat({':'}, 1, length(szX)));
mwTag = 31681;
if srcLab == 0
    % Everyone has the matrix, so we can index directly into it.
    idx.subs{codistr.Dimension} = partitionIndices(codistr.Partition);
    X = subsref(X,idx);
else
    % Send the appropriate portion of the matrix to each of the other labs.
    if labindex == srcLab
        for destLab = 1:numlabs
            if destLab ~= srcLab
                idx.subs{codistr.Dimension} = partitionIndices(codistr.Partition, destLab);
                labSend(subsref(X,idx), destLab, mwTag);
            end
        end
        % Done sending to others.  Retain only the portion we need for our local part.
        idx.subs{codistr.Dimension} = partitionIndices(codistr.Partition, srcLab);
        X = subsref(X,idx);
    else
        X = labReceive(srcLab, mwTag);
    end
end

end % End of getLocalPart.
