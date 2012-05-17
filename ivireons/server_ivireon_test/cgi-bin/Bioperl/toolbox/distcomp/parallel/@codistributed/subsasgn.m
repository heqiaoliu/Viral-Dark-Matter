function A = subsasgn(A,aidx,B)
%SUBSASGN Subscripted assignment for codistributed array
%   A(I) = B
%   A(I,J) = B for 2D codistributed arrays
%   A(I1,I2,I3,...,IN) = B for ND codistributed arrays
%   
%   A{...} indexing is not supported for codistributed cell arrays.
%   A.field indexing is not supported for codistributed arrays of structs.
%   
%   To expand an ND codistributed array A to higher dimensions via
%   A(I1,I2,...IN,IN+1) = B, B must be a scalar.
%   
%   A(I) = B cannot be used to expand the size of A.
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.eye(N);
%       D(1,N) = pi
%   end
%   
%   See also SUBSASGN, CODISTRIBUTED, CODISTRIBUTED/EYE.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/05/14 16:51:23 $

% We neither support '.', or '{}', nor do we support multiple levels that start
% with '()', such as D(1).MyFieldName.
if ~isequal(aidx(1).type,'()') || (length(aidx) > 1)
    error('distcomp:codistributed:subsasgn:badIndexType', ...
          'Distributed SUBSASGN currently only supports () indexing.')
end

% Gather all distributed indices and find all logical indices.
for k = 1:length(aidx(1).subs)
    if isa(aidx(1).subs{k}, 'codistributed')
        aidx(1).subs{k} = gather(aidx(1).subs{k});
    end
    if islogical(aidx(1).subs{k})
        aidx(1).subs{k} = find(aidx(1).subs{k});
    end
end

if ~isa(A,'codistributed') && isa(B,'codistributed')
    % notDefine(...,subs,...) = codistributed
    U(aidx(1).subs{:}) = gather(B);
    A = codistributed(U);
    return
end

% This implementation only supports codistributor1d.
codistributed.pVerifyUsing1d('subsasgn', A, B); %#ok<DCUNK> private static

% A(...,s,...) = B
aDist = getCodistributor(A);
d = aDist.Dimension;
sizea = size(A);
if length(aidx.subs) >= ndims(A)
    % Ensure that aidx and sizea include the distribution dimension of A.
    sizea(end+1:aDist.Dimension) = 1;
    aidx.subs(end+1:aDist.Dimension) = {1};
    s = aidx.subs{d};
    if any(s(:)<=0) || any(~isfinite(s(:))) || any(s(:) ~= floor(s(:)));
        error('distcomp:codistributed:subsasgn:badsubscript', ...
              'Subscript indices must either be real positive integers or logicals.')
    end
    if isColonIndex(s)
        s = 1:sizea(d);
    end
    if any(s > size(A,d))

        % Subscript exceeds distributed dimension, expand last partition

        if ~isscalar(B)
            error('distcomp:codistributed:subsasgn:notYetNonScalar', ...
                  ['Distributed SUBASGN does not yet support expansion ', ...
                  'with a nonscalar right hand side.'])
        end
        expand = max(s) - sizea(d);
        Aloc = getLocalPart(A);
        p = aDist.Partition;
        p(end) = p(end) + expand;
        if labindex == numlabs
           [e,f] = partitionIndices(p);
           f = f + expand;
           lastidx = aidx;
           lastidx.subs{d} = s(s >= e & s <= f)-e+1;
           zeroElem = distributedutil.Allocator.create([1,1], Aloc);
           Aloc = subsasgn(Aloc, lastidx, zeroElem);
        else
            % Assignment on the last lab might have caused expansion in
            % many dimensions - not just the distributed dimension.
            % Therefore on labs other than the last one we have to check if
            % expansion happens and if so we need to grow the local part
            % accordingly.
            [e,f] = partitionIndices(p);
            if e <= f % if there is any local data
                
                % check all non-distributed indices if they are being expanded

                expandF = 0;
                for i = 1:length(aidx.subs)
                    if i == d, continue; end % skip distributed dimension

                    ss = aidx.subs{i};
                    if isColonIndex(ss)
                        ss = 1:sizea(d);
                    end
                    if any(ss > size(A, i))
                        expandF = 1;
                        break;
                    end
                end
                if expandF
                    lastidx = aidx;
                    lastidx.subs{d} = 1;
                    zeroElem = distributedutil.Allocator.create([1,1], Aloc);
                    Aloc = subsasgn(Aloc,lastidx, zeroElem);
                end
            end
        end
        A = codistributed.build(Aloc, codistributor('1d',d,p), 'obsolete:calculateSize');
        aDist = getCodistributor(A);
    end

    if isscalar(B)

        % codistributed(...,subs,...) = scalar

        if isa(B,'codistributed')
           B = gather(B);
        end
        [e,f] = globalIndices(A, aDist.Dimension, labindex);
        aidx.subs{d} = s(s >= e & s <= f)-e+1;
        A = codistributed.build(subsasgn(getLocalPart(A),aidx,B), getCodistributor(A), 'obsolete:calculateSize');
    else

        At = subsref(A,aidx);

        if prod(size(At)) ~= prod(size(B)) %#ok<PSIZE> Don't call numel as we haven't overloaded it yet.
           error('distcomp:codistributed:subsasgn:sizeMismatch', ...
                 'Subscripted assignment dimension mismatch.');
        end

        if ~isa(At,'codistributed')
            [e,f] = globalIndices(A, aDist.Dimension, labindex);
            aidx.subs{d} = s(s >= e & s <= f)-e+1;
            % Currently set this to calculate the size.  It is possible that
            % 'noCommunication' would work here.
            A = codistributed.build(subsasgn(getLocalPart(A),aidx,B), ...
                                    getCodistributor(A), ...
                                    'obsolete:calculateSize');
            return
        elseif ~isa(B,'codistributed')
            B = reshape(B,size(At));
            B = codistributed.pConstructFromReplicated(B, getCodistributor(At)); %#ok<DCUNK> Calling a private static method.
        else % codistributed(B)
            if isequal(size(At),size(B))
                B = redistribute(B,getCodistributor(At));
            else
                %Not efficient. Need distributed/reshape to be implemented
                B = reshape(gather(B),size(At));
                B = codistributed.pConstructFromReplicated(B, getCodistributor(At));%#ok<DCUNK> Calling a private static method.
            end
        end

        % codistributed(...,subs,...) = codistributed

        bDist = getCodistributor(B);
        j = globalIndices(B, bDist.Dimension, labindex);
        [e,f] = globalIndices(A, aDist.Dimension, labindex);
        if all(s(j) >= e & s(j) <= f)

            % Important special case, no communication required.

            aidx.subs{d} = s(j)-e+1;
            Aloc = subsasgn(getLocalPart(A),aidx,getLocalPart(B));

        else

            % General case.

            Aloc = getLocalPart(A);
            bidx = substruct('()',repmat({':'},1,ndims(B)));
            mwTag = 31898;
            for p = 1:numlabs
                j = globalIndices(B, bDist.Dimension, p);
                for q = 1:numlabs
                    [e,f] = globalIndices(A, aDist.Dimension, q);
                    k = find(s(j) >= e & s(j) <= f);
                    if ~isempty(k) && ~isempty(j)
                        aidx.subs{d} = s(j(k))-e+1;
                        bidx.subs{d} = j(k)-j(1)+1;
                        if p == q && p == labindex
                            Aloc = subsasgn(Aloc,aidx,subsref(getLocalPart(B),bidx));
                        elseif p == labindex
                            labSend(subsref(getLocalPart(B),bidx),q,mwTag);
                        elseif q == labindex
                            Aloc = subsasgn(Aloc,aidx,labReceive(p,mwTag));
                        end
                    end
                end
            end

        end
        A = codistributed.build(Aloc, getCodistributor(A), 'obsolete:calculateSize');
    end

elseif length(aidx.subs) == 1

    % Linear indexing

    s = aidx.subs{1};
    if any(s(:)<=0) || any(~isfinite(s(:))) || any(s(:) ~= floor(s(:)));
        error('distcomp:codistributed:subsasgn:badsubscript', ...
              'Subscript indices must either be real positive integers or logicals.')
    end
    if isColonIndex(s)
        s = 1:prod(sizea);
    end
    if any(s > prod(sizea))
        error('distcomp:codistributed:subsasgn:notYetLinear', ...
              ['Distributed SUBASGN does not yet support expansion ',...
              'with linear indexing.'])
    end
    c = prod(sizea(1:end-1));

    if isscalar(B)

        % codistributed(s) = scalar

        if isa(B,'codistributed')
           B = gather(B);
        end

        % This algorithm needs A to be distributed by last dimension.
        % Not efficient for A that is not distributed by last dimension.
        D = A;
        A = redistribute(A, codistributor('1d',ndims(A)));
        [e,f] = globalIndices(A, ndims(A), labindex);
        e = c*(e-1)+1;
        f = c*f;
        aidx.subs{1} = s(s >= e & s <= f)-e+1;
        A = codistributed.build(subsasgn(getLocalPart(A),aidx,B), getCodistributor(A), 'obsolete:calculateSize');
        A = redistribute(A,getCodistributor(D));

    else

        % codistributed(s) = array

        if isa(B,'codistributed')
            B = gather(B);
        end

        if length(s) ~= prod(size(B)) %#ok<PSIZE> Don't call numel as we haven't overloaded it yet.
           error('distcomp:codistributed:subsasgn:sizeMismatch', ...
                 'Subscripted assignment dimension mismatch.');
        end

        % This algorithm needs A to be distributed by last dimension.
        % Not efficient for A that is not distributed by last dimension.
        D = A;
        A = redistribute(A, codistributor('1d',ndims(A)));
        [e,f] = globalIndices(A, ndims(A), labindex);
        e = c*(e-1)+1;
        f = c*f;
        j = find(s >= e & s <= f);
        aidx.subs{1} = s(j)-e+1;
        A = codistributed.build(subsasgn(getLocalPart(A),aidx,B(j)), getCodistributor(A), 'obsolete:calculateSize');
        A = redistribute(A, getCodistributor(D));

    end

else
    error('distcomp:codistributed:subsasgn:notYetFewSubscripts', ...
          ['Distributed SUBASGN does not yet support indexing with k ', ...
          'subscripts where 1 < k < ndims.'])
end
