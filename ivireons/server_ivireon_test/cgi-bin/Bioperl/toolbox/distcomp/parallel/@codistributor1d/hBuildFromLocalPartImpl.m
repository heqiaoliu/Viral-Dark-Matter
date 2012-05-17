function dist = hBuildFromLocalPartImpl(dist, L, buildOption)
; %#ok<NOSEM> % Undocumented
  % Implementation of hBuildFromLocalPartImpl for codistributor1d.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/07/14 03:53:31 $

if ~distributedutil.Allocator.supportsCreation(L)
    error('distcomp:codistributor1d:BuildFromLocalPart:UnsupportedClass',...
          ['Class %s is not supported as the underlying class for ' ...
           'codistributed arrays.'], class(L));
end
    
if (buildOption == distributedutil.BuildOption.NoCommunication ...
    || buildOption == distributedutil.BuildOption.CommunicationAllowed)
    % We are using the currently documented API.
    dist = buildWithCompleteDist(dist, L, buildOption);
elseif buildOption == distributedutil.BuildOption.CalculateSize
    % Use implementation of obsolete API.
    dist = obsoleteBuildWithMissingSize(dist, L);
elseif buildOption == distributedutil.BuildOption.MatchLocalParts
    % Use implementation of obsolete API.
    dist = obsoleteBuildMatchLocalParts(dist, L);
end

end % End of buildFromLocalPartsImpl.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dist = buildWithCompleteDist(dist, L, buildOption)
% Verify that codistributor is complete and matches the local part.  All of the
% information in the codistributor must be consistent with the local part.  This
% function implements the specification for the documented API.

if ~dist.isComplete()
    error('distcomp:codistributor1d:build:IncompleteCodistributor', ...
              ['Codistributor must be complete when building a codistributed ', ...
               'array from its local parts.']);
end

isCommAllowed = (buildOption == distributedutil.BuildOption.CommunicationAllowed);
% Communication is required to form the codistributed array to
% perform extra checking across all labs.
% L can be a MATLAB array of any class, sparsity, complexity and size.
% All except complexity must match across all labs. 
if isCommAllowed 
    if ~isreplicated({'buildWithCompleteDist', class(L), issparse(L), class(dist), ...
                      dist.Dimension, dist.Partition})
        error('distcomp:codistributed:attributeMismatch', ...
              ['Local part must have the same class and', ...
               ' sparsity on all labs. All other arguments also need to be replicated.']);
    end
end

% Error check the size of L against the sizes stored in the codistributor.
if ~isequal(size(L), dist.hLocalSize())
    ex = MException('distcomp:codistributed:buildFromLocal:IncorrectSize', ...
                    ['Size of local part (%s) does not match the expected size '...
                     'of the local part (%s).'], ...
                    num2str(size(L)), num2str(dist.hLocalSize()));
    throw(ex);
end
end % End of buildWithCompleteDist

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dist = obsoleteBuildWithMissingSize(dist, L)
% Implementation of obsolete API.  Dimension and partition have been set, so we
% don't perform any error checks.  The global size, however, is missing.
% Returns a codistributor with the global size set correctly.
dim = dist.Dimension;
part = dist.Partition;
% Check locally that the array size matches the partition.
if size(L,dim) ~= part(labindex)
    error('distcomp:codistributed:noCommDimParL', ...
          'SIZE(L,DIM) must equal to PART(LABINDEX).');
end
siz = obsoleteGetGlobalSize(size(L), dim, part);
dist = dist.hGetCompleteForSize(siz);
end % End of buildWithMissingSize

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dist = obsoleteBuildMatchLocalParts(dist, L)
% Implementation of legacy API from R2009a and earlier.  Construct a
% codistributed array by matching the sizes of the local parts.
isCommAllowed = isequal(dist.Dimension, codistributor1d.unsetDimension) ...
    || isequal(dist.Partition, codistributor1d.unsetPartition);
if isCommAllowed
    if ~isreplicated({'MatchLocalParts', class(L), issparse(L), class(dist)})
        error('distcomp:codistributed:attributeMismatch', ...
              ['Local part must have the same class and', ...
               ' sparsity on all labs. All other arguments also need to ' ...
               'be replicated.']);
    end
end
[dim, part] = obsoleteMatchLocalParts(dist, L);
siz = obsoleteGetGlobalSize(size(L), dim, part);
dist = codistributor1d(dim, part, siz);    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = obsoleteGetGlobalSize(localSize, ddim,part)
% This is legacy code from R2009a and prior.  Return the global size of the
% array based on the size of the local part, the distribution dimension and the
% partition.
s = localSize;
ddimsize = sum(part);
if ddim <= length(s)
    s(ddim) = ddimsize;
else
    s(length(s)+1:ddim) = 1;
    s(ddim) = ddimsize;
end
if ddimsize == 1 && length(s) > 2
    % remove trailing singleton dimensions
    nonOne = find(s~=1,1,'last');
    if isempty(nonOne)
        nonOne = 0;
    end
    e = max(2,nonOne);
    s = s(1:e);
end
end % End of getGlobalSize.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dim, part] = obsoleteMatchLocalParts(dist, L)
% This is legacy code from R2009a and prior.  Given some partial information in
% the codistributor and the sizes of L, figure out the correct distribution
% dimension and partition to use.
setDistribdim = true;
setPartition  = true;
dim = dist.Dimension;
if isequal(dist.Dimension, codistributor1d.unsetDimension)
    setDistribdim = false;
end

part = dist.Partition;
if isequal(dist.Partition, codistributor1d.unsetPartition)
    setPartition = false;
end

% If DIM/PAR were not specified, then deduce them from size(L)
% If DIM/PAR were specified, then check them against size(L)
szL = size(L);
maxNdimsL = gop(@max, ndims(L));
pad = @(x,n) [x ones(1,n)];
padSzL = pad(szL, maxNdimsL - length(szL));
padSzLs = gcat(padSzL, 1);

% There should be at most 1 place where the padded sizes differ
k = find(min(padSzLs, [], 1) ~= max(padSzLs, [], 1));

if length(k) > 1 || (setDistribdim && isscalar(k) && k~=dim)
    if ~setDistribdim
        error('distcomp:codistributed:sizeMismatchL', ...
              'Sizes of L incompatible in CODISTRIBUTED(L).');
    else
        error('distcomp:codistributed:sizeMismatchDim', ...
              'Sizes of L incompatible with DIM in CODISTRIBUTED(L,''1d'',DIM).');
    end
end

% Derive distribution dimension and partition.
if isempty(k)
    % If all sizes are equal, use last dimension
    dimDerived = size(padSzLs,2);
else % isscalar(k)
    dimDerived = k;
end
if setDistribdim
    if isscalar(k) && dim ~= dimDerived
        error('distcomp:codistributed:dimDerived', ...
              'CODISTRIBUTED(L,''1d'',DIM) requires DIM to match sizes of L.')
    end
else
    dim = dimDerived;
end

if dim > size(padSzLs,2)
    parDerived = ones(1,numlabs);
else
    parDerived = padSzLs(:,dim)';
end
if setPartition
    if ~isequal(part,parDerived)
        error('distcomp:codistributed:distParDerived', ...
              'CODISTRIBUTED(L,''1d'',DIM,PART) requires PART to match sizes of L.')
    end
else
    part = parDerived;
end
end  % End of matchLocalParts.
