function varargout = subsref(A,aidx)
%SUBSREF Subscripted reference for codistributed array
%   B = A(I)
%   B = A(I,J)
%   B = A(I,J,K,...)
%   
%   The index I in A(I) must be :, scalar or a vector.
%   
%   A{...} indexing is not supported for codistributed cell arrays.
%   A.field indexing is not supported for codistributed arrays of structs.
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.eye(N);
%       one = D(N,N)
%   end
%   
%   See also SUBSREF, CODISTRIBUTED, CODISTRIBUTED/EYE.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/10/12 17:29:05 $

% This method needs to have varargout so that users see the following error
% message when trying to use struct indexing on a distributed array:
if ~isequal(aidx(1).type,'()') || (length(aidx) > 1)
    error('distcomp:codistributed:subsref:badIndexType', ...
          'Distributed SUBSREF currently only supports () indexing.')
end

error(nargoutchk(0, 1, nargout, 'struct'));

% This implementation only supports codistributor1d.
codistributed.pVerifyUsing1d('subsref', A); %#ok<DCUNK> private static

% B = A(subs). Minimal communication between labs.
orgLengthSubs = length(aidx(1).subs);
[A, Aloc, aidx, partA, bDistDim, sizeb] = iPrepIndexAndCalcSizeOfB(A, aidx);

% Error check subscripts in the distribution dimension here because all labs are
% still working with the replicated index.  This allows them all to throw an
% error at the same time.
subInBDistDim = aidx.subs{bDistDim};
% TODO: Fix this here.  We need to colonize the index in the distribution
% dimension when there are multiple indices.
if sum(size(subInBDistDim)>1)>1
    error('distcomp:codistributed:subsref:badSubscriptSize', ...
          'Distributed SUBSREF currently only supports vector subscripts.')
end

% We need to error check the index in the distribution dimension of B ourselves
% because we will manipulate it further on.  The builtin subsref will error
% check the indices in the other dimensions.
if any(subInBDistDim(:)<=0) || any(~isfinite(subInBDistDim(:))) ...
        || any(subInBDistDim(:) ~= floor(subInBDistDim(:)))
    error('distcomp:codistributed:subsref:badsubscript', ...
          'Subscript indices must either be real positive integers or logicals.')
end

sizea = size(A);
% Let smax store the upper bound on the permissible index value.
smax = sizea;
smax(orgLengthSubs) = prod(smax(orgLengthSubs:end));
smax(end+1:bDistDim) = 1;
% TODO: Can this be simplified to any(subInBDistDim(:) > smax(bDistDim))?
if (orgLengthSubs == 1 && any(subInBDistDim(:) > smax(1))) ...
        || (orgLengthSubs > 1 && any(subInBDistDim(:) > smax(bDistDim)))
    error('distcomp:codistributed:subsref:badSubscriptDim', ...
          'Index exceeds matrix dimension.')
end

% Subscript ranges

% Calculate vectors of length numlabs storing the start and end indices of A in
% the distribution dimension that reside on each lab.
endA = cumsum(partA);
startA = endA - partA + 1;
% If the user used linear indexing, we have already colonized A.  If the user
% used > 1 index but < ndims(A) indices, we fold the last dimensions of A, so we
% have to update the start and end indices accordingly.
lengthsubs = length(aidx.subs);
% Note that at this point, lengthsubs is always > 1 as the output of
% iPrepIndexAndCalcSizeOfB.
foldLastDimensions = lengthsubs < length(sizea);
if foldLastDimensions
    strideInLastIndexDim = prod(sizea(lengthsubs:end-1));
    startA = strideInLastIndexDim*(startA-1)+1;
    endA = strideInLastIndexDim*endA;
end

% Determine partition of B so that little communication is required.

% Let the partition of B be such that each lab stores the same elements of A as
% it has.
% TODO: Figure out how this maps into the communicating subsref.
partB = zeros(1,numlabs);
for k = 1:numlabs
    partB(k) = sum((startA(k) <= subInBDistDim) & (subInBDistDim <= endA(k)));
end
endB = cumsum(partB);
startB = endB-partB+1;

% Check if no communication is required
% Determine q and r so that A(...,subInBDistDim(q),...) is on this lab and
% B(..., q(r),...)  is on this lab.

% Find all the subscripts into A in the dimension bDistDim that refer to values
% that we have on this lab.
q = find((startA(labindex) <= subInBDistDim) & (subInBDistDim <= endA(labindex)));
% Find those elements of q that will end up in elements of B that we store on
% this lab.
r = find((startB(labindex) <= q) & (q <= endB(labindex)));

if isinparfor
    % Does the indexing into my local part create all of B?  We ignore where it
    % should end up and put all of it here.
    if length(r) == sum(partB)
        aidx.subs{bDistDim} = subInBDistDim(q(r))-startA(labindex)+1;
        B = subsref(Aloc,aidx);
        % Since we are inside a for-drange statement and are returning a regular MATLAB
        % array, we don't inspect or modify the sparsity of B.  Rather, we just
        % return what regular MATLAB indexing gives us.
        varargout{1} = B;
        return
    else
        error('distcomp:codistributed:subsref:inparfor', '%s%s', ...
              'Inside a FOR-DRANGE loop, a subscript can only ', ...
              'access the local portion of a codistributed array.')
    end

elseif length(r) == partB(labindex)
    % The indexing into my local part all ends up on this lab.  We therefore don't
    % need any message passing.
    aidx.subs{bDistDim} = subInBDistDim(q(r))-startA(labindex)+1;
    Bloc = subsref(Aloc,aidx);

else
    sizea = size(A);
    sizeBloc = sizeb;
    sizeBloc(bDistDim) = partB(labindex);
    Bloc = distributedutil.Allocator.create(sizeBloc, Aloc);
    Bloc = iGetBlocWithCommunications(Aloc, Bloc, aidx, endA, startA, endB, startB, bDistDim, sizea);
end

% Result is a codistributed array
codistr = codistributor1d(bDistDim, partB, sizeb);
B = codistributed.pDoBuildFromLocalPart(Bloc, codistr); %#ok<DCUNK> Calling a private static method.
varargout{1} = B;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [A, Aloc, aidx, partA, bDistDim, sizeb] = iPrepIndexAndCalcSizeOfB(A, aidx)
% Pre-process aidx and calculate the size of B as well as its distribution
% dimension.
% aidx is returned in a form such that aidx.subs is of length >= bDistDim.
lengthsubs = length(aidx.subs);
nda = ndims(A);
for k = 1:lengthsubs
   if isa(aidx.subs{k}, 'codistributed')
      aidx.subs{k} = gather(aidx.subs{k});
   end
   if islogical(aidx.subs{k})
      aidx.subs{k} = find(aidx.subs{k});
   end
end

aDist = getCodistributor(A);
if lengthsubs > 1
    % More than one index used, e.g. A(X, Y), A(:, [1:10; 21:30], 5), etc.
    % 1) The number of indices may exceed ndims(A), but the extra indices better be
    % 1 or ':'.
    % 2) The number of indices may be less than ndims(A), in which case we fold the
    % last dimensions of A.
    % 3) The shape of the indices is ignored, and they are treated as the colonized
    % versions.
    %
    % We plan on letting B be distributed either across its last dimension, or
    % across aDist.Dimension.  The number of dimensions of B will equal the
    % number of indices used into A.  
    sizea = size(A);
    if lengthsubs >= nda
        % There are at least as many indices as ndims(A).  The last "real" index
        % (i.e. those that aren't required to be equivalent to 1) is in the last
        % dimension of A.
        bDistDim = aDist.Dimension;
        % Ensure that aidx and sizea include the distribution dimension of A and B.
        sizea(end+1:aDist.Dimension) = 1;
        aidx.subs(end+1:aDist.Dimension) = {1};
        lengthsubs = length(aidx.subs);
        if isColonIndex(aidx.subs{bDistDim})
            aidx.subs{bDistDim} = 1:sizea(bDistDim); % Expand so we can divy up between labs.
        end
    else
        if aDist.Dimension ~= nda
            % Redistribute A so that the local parts are storing contiguous blocks of the
            % linear index of A.
            aDist = codistributor('1d',nda, codistributor1d.defaultPartition(sizea(nda)));
            A = redistribute(A, aDist);
            aDist = getCodistributor(A);
        end
        % At this point, A is distributed across its last dimension, but the last index
        % is in a dimension strictly less than that.
        bDistDim = lengthsubs;
        if isColonIndex(aidx.subs{bDistDim})
            aidx.subs{bDistDim} = 1:prod(sizea(bDistDim:end));
        end
    end
    % The shape of the indices does not matter since more than one index was
    % specified.  We therefore convert all indices into column vectors.
    for k = 1:lengthsubs
        if ~isColonIndex(aidx.subs{k})
            aidx.subs{k} = aidx.subs{k}(:);
        end
    end

    partA = aDist.Partition;
    Aloc = getLocalPart(A);
    % Figure out the global size of B.
    sizeb = zeros(1,lengthsubs);
    for k = 1:length(sizeb);
        if isColonIndex(aidx.subs{k})
            sizeb(k) = size(A,k);
        else
            sizeb(k) = length(aidx.subs{k});
        end
    end
else
    % Only one index used, i.e. linear indexing, such as A(:), A(1),
    % A([1:10; 21:30]), etc. 
    % When performing indexing with one input, i.e. A(X),, the output has the same
    % shape as the index matrix X, except when both A and X are vectors.  When
    % that is true, A(X) has the same shape as A, not X.
    sizea = size(A);
    % The shape of B depends on whether A is a vector as well as how it is being
    % indexed.  We now assume that A is being indexed by an index vector (and
    % not a matrix), and check whether the result is a row or a column vector.
    isAvector = sum(sizea > 1) == 1;
    isBColumn = isColonIndex(aidx.subs{1}) ...
             || (isAvector && sizea(1) > 1) ...
             || (~isAvector && size(aidx.subs{1}, 1) > 1);
    % Convert A into a distributed column vector.  Note that this may be extremely
    % inefficient: Colonize can result in an all-to-all communication, and this
    % we go this code path to retrieve a single element of A, such as, say, A(1).
    A = colonize(A);
    aDist = getCodistributor(A);
    Aloc = getLocalPart(A);
    partA = aDist.Partition;
    % Change the index from being a linear index into being a tuple index so that
    % subsequent use of subsref with aidx will not lead to a reshape.  We have
    % already done the reshaping here, so we don't want it to take place the
    % second time.
    if isBColumn
        % B should be a column vector.
        bDistDim = 1;
        aidx.subs = {aidx.subs{1} 1};
    else
        % B should be a row vector.  However, we have re-shaped A and Aloc into column
        % vectors.  We therefore have to change them into row vectors so that B
        % automatically gets the rigth shape.
        bDistDim = 2;
        aidx.subs = {1 aidx.subs{1}};
        Aloc = reshape(Aloc,[1, numel(Aloc)]);  
    end
    if isColonIndex(aidx.subs{bDistDim})
        aidx.subs{bDistDim} = 1:prod(sizea);
    end
    sizeb = [1 1];
    sizeb(bDistDim) = length(aidx.subs{bDistDim});
end
end % End of iPrepIndexAndCalcSizeOfB.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Bloc = iGetBlocWithCommunications(Aloc, Bloc, aidx, endA, startA, endB, startB, bDistDim, sizea)

subInBDistDim = aidx.subs{bDistDim};
% Subscript structure for use with builtin subsref and subsasgn

bidx = substruct('()',repmat({':'}, 1, length(sizea)));

% Double loop over labs.  Determine q and r so that A(...,subInBDistDim(q(r)),...)
% is on lab srcLab and B(...,q(r),...) is on lab destLab.

mwTag = 32006;
for srcLab = 1:numlabs
    q = find((startA(srcLab) <= subInBDistDim) & (subInBDistDim <= endA(srcLab)));
    if ~isempty(q)
        for destLab = 1:numlabs
            r = find((startB(destLab) <= q) & (q <= endB(destLab)));
            if ~isempty(r)
                aidx.subs{bDistDim} = subInBDistDim(q(r)) - startA(srcLab) + 1;
                bidx.subs{bDistDim} = q(r) - startB(destLab) + 1;
                if destLab == srcLab && srcLab == labindex
                    Bloc = subsasgn(Bloc, bidx, subsref(Aloc, aidx));
                elseif srcLab == labindex
                    labSend(subsref(Aloc, aidx), destLab, mwTag)
                elseif destLab == labindex
                    Bloc = subsasgn(Bloc, bidx, labReceive(srcLab, mwTag));
                end
            end
        end
    end
end

end % End of iGetBlocWithCommunications.
