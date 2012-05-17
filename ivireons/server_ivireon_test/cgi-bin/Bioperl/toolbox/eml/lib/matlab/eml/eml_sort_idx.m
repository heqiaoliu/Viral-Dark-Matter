function idx = eml_sort_idx(x,col)
%Embedded MATLAB Private Function

%   EML_SORT_IDX(X,COL) provides SORTROWS functionality using a merge
%   sort algorithm.  The output is an index vector of eml_index_class such
%   that v(idx,:) is the sorted result.  For sorting vectors, COL must be
%   'a' for ascending or 'd' for descending.  Input x must be a vector or
%   2D matrix.

%   Copyright 2004-2008 The MathWorks, Inc.
%#eml

% eml_must_inline;
eml_allow_enum_inputs;
eml_assert(nargin == 2, 'Not enough input arguments.');
eml_prefer_const(col);
ONE = ones(eml_index_class);
TWO = cast(2,eml_index_class);
if ischar(col)
    % Sort a vector.
    n = cast(eml_numel(x),eml_index_class);
else
    % Sort a matrix.
    n = cast(size(x,1),eml_index_class);
end
np1 = eml_index_plus(n,ONE);
idx0 = ones(n,1,eml_index_class);
idx = (ONE:n).';
if isempty(x)
    return
end
% Quick merge of neighbors.
for k = ONE:TWO:eml_index_minus(n,1)
    if eml_sort_le(x,col,k,eml_index_plus(k,1))
    else
        idx(k) = eml_index_plus(k,1);
        idx(eml_index_plus(k,1)) = k;
    end
end
i = cast(2,eml_index_class);
while i <= n
    i2 = eml_index_times(i,2);
    j = ONE;
    pEnd = eml_index_plus(j,i);
    while pEnd < np1
        p = j;
        q = pEnd;
        qEnd = eml_index_plus(j,i2);
        if qEnd > np1
            qEnd = np1;
        end
        k = ONE;
        kEnd = eml_index_minus(qEnd,j);
        while k <= kEnd
            if eml_sort_le(x,col,idx(p),idx(q))
                idx0(k) = idx(p);
                p = eml_index_plus(p,1);
                if p == pEnd
                    while q < qEnd
                        k = eml_index_plus(k,1);
                        idx0(k) = idx(q);
                        q = eml_index_plus(q,1);
                    end
                end
            else
                idx0(k) = idx(q);
                q = eml_index_plus(q,1);
                if q == qEnd
                    while p < pEnd
                        k = eml_index_plus(k,1);
                        idx0(k) = idx(p);
                        p = eml_index_plus(p,1);
                    end
                end
            end
            k = eml_index_plus(k,1);
        end
        p = eml_index_minus(j,1);
        for k = ONE:kEnd
            idx(eml_index_plus(p,k)) = idx0(k);
        end
        j = qEnd;
        pEnd = eml_index_plus(j,i);
    end
    i = i2;
end
