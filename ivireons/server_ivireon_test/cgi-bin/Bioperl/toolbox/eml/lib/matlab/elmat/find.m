function [i,j,v] = find(x,kin,opt)
%Embedded MATLAB Library Function

%   Limitations:
%   There are no limitations for fixed-size x.
%   For variable-size x:
%   1. FIND issues an error if a variable-size input array becomes a row
%   vector at run-time.  This is because Embedded MATLAB would return a
%   column vector when MATLAB would return a row vector.  Currently, if
%   Embedded MATLAB returned a row vector, too, the outputs could not be
%   variable-length vectors, i.e. they would have shape :k-by-:k rather
%   than 1-by-:k or :k-by-1.  This limitation does not apply when the input
%   is scalar or a variable-length row vector.
%   2. The shape of empty outputs, 0-by-0, 0-by-1, or 1-by-0, depends on
%   the upper bounds of the size of x and may not match MATLAB when the
%   input array x happens to be a scalar or [] at run-time.  If x is a
%   variable-length row vector, an empty will have size 1-by-0, otherwise
%   it will have size 0-by-1.

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_assert(eml_option('VariableSizing'), ...
    'FIND requires variable sizing.');
eml_assert(nargin > 0, 'Not enough input arguments.');
nx = eml_numel(x);
xZERO = eml_scalar_eg(x);
if nargin > 1
    eml_prefer_const(kin);
    eml_lib_assert(isscalar(kin) && floor(kin) == kin && kin > 0, ...
        'MATLAB:find:NotScalarInt', ...
        'Second argument must be a positive scalar integer.');
    k = min(kin,nx);
else
    k = nx;
end
assert(k <= nx); %<HINT>
if nargin == 3
    if strcmp(opt,'first')
        first = true;
    elseif strcmp(opt,'last')
        first = false;
    else
        eml_assert(false, ...
            'Invalid search option. Must be ''first'' or ''last''');
    end
else
    first = true;
end
if eml_is_const(isempty(x)) && isempty(x)
    if (eml_is_const(isvector(x)) && isvector(x)) || ...
            (eml_is_const(size(x)) && isequal(size(x),[0,0]))
        i = zeros(size(x));
        j = zeros(size(x));
        v = x;
    else
        i = zeros(0,1);
        j = zeros(0,1);
        v = reshape(x,[0,1]);
    end
    return
end
if eml_is_const(isscalar(x)) && isscalar(x)
    if (islogical(x) && x(1)) || (~islogical(x) && x(1) ~= xZERO)
        i = 1;
        j = 1;
        v = x(1);
    else
        i = [];
        j = [];
        v = x([]);
    end
    return
end
idx = 0;
if eml_const( ...
        eml_is_const(isvector(x)) && isvector(x) && ...
        eml_is_const(size(x,1)) && size(x,1) == 1)
    % Input is a row vector, so return row vectors.
    % eml.varsize('i','j','v',[1,k],[0,1]);
    i = eml.nullcopy(zeros(1,0)); %#ok<NASGU>
    i = eml.nullcopy(zeros(1,k));
    j = eml.nullcopy(zeros(1,0)); %#ok<NASGU>
    j = eml.nullcopy(zeros(1,k));
    v = eml.nullcopy(eml_expand(xZERO,[1,0])); %#ok<NASGU>
    v = eml.nullcopy(eml_expand(xZERO,[1,k]));
    isRow = true;
else
    % Check to see whether a variable-size array has degenerated to a
    % row-vector.  We must error because MATLAB will return a row-vector in
    % this case.  Currently, if we were to do the same, our output arrays
    % would end up with :k-by-:k bounds instead of :k-by-1 or 1-by-:k.
    eml_lib_assert(~isvector(x) || size(x,1) ~= 1 || size(x,2) <= 1, ...
        'EmbeddedMATLAB:find:incompatibleShape', ...
        ['A variable-size array input to FIND in Embedded MATLAB ', ...
        'must not reduce to a row vector at run-time.']);
    % Otherwise return column vectors.
    % eml.varsize('i','j','v',[k,1],[1,0]);
    i = eml.nullcopy(zeros(0,1)); %#ok<NASGU>
    i = eml.nullcopy(zeros(k,1));
    j = eml.nullcopy(zeros(0,1)); %#ok<NASGU>
    j = eml.nullcopy(zeros(k,1));
    v = eml.nullcopy(eml_expand(xZERO,[0,1])); %#ok<NASGU>
    v = eml.nullcopy(eml_expand(xZERO,[k,1]));
    isRow = false;
end
if nargout > 1
    [m,n] = size(x);
    if nx == 0
        if isRow
            i = zeros(1,0);
            j = zeros(1,0);
            v = eml_expand(xZERO,[1,0]);
        else
            i = zeros(0,1);
            j = zeros(0,1);
            v = eml_expand(xZERO,[0,1]);
        end
    elseif first
        ii = 1;
        jj = 1;
        while jj <= n
            if (islogical(x) && x(ii,jj)) || ...
                    (~islogical(x) && x(ii,jj) ~= xZERO)
                idx = idx + 1;
                i(idx) = ii;
                j(idx) = jj;
                v(idx) = x(ii,jj);
                if idx >= k
                    break
                end
            end
            ii = ii + 1;
            if ii > m
                ii = 1;
                jj = jj + 1;
            end
        end
        assert(idx <= k); %<HINT>
        if k == 1
            if idx == 0
                if isRow
                    i = zeros(1,0);
                    j = zeros(1,0);
                    v = eml_expand(xZERO,[1,0]);
                else
                    i = zeros(0,1);
                    j = zeros(0,1);
                    v = eml_expand(xZERO,[0,1]);
                end
            end
        else
            i = i(1:idx);
            j = j(1:idx);
            v = v(1:idx);
        end
    else
        ii = m;
        jj = n;
        while jj > 0
            if (islogical(x) && x(ii,jj)) || ...
                    (~islogical(x) && x(ii,jj) ~= xZERO)
                idx = idx + 1;
                i(idx) = ii;
                j(idx) = jj;
                v(idx) = x(ii,jj);
                if idx >= k
                    break
                end
            end
            ii = ii - 1;
            if ii < 1
                ii = m;
                jj = jj - 1;
            end
        end
        assert(idx <= k); %<HINT>
        if k == 1
            if idx == 0
                if isRow
                    i = zeros(1,0);
                    j = zeros(1,0);
                    v = eml_expand(xZERO,[1,0]);
                else
                    i = zeros(0,1);
                    j = zeros(0,1);
                    v = eml_expand(xZERO,[0,1]);
                end
            end
        else
            i = i(1:idx);
            j = j(1:idx);
            v = v(1:idx);
            i = flipv(i);
            j = flipv(j);
            v = flipv(v);
        end
    end
else
    if first
        for ii = 1:nx
            if (islogical(x) && x(ii)) || (~islogical(x) && x(ii) ~= xZERO)
                idx = idx + 1;
                i(idx) = ii;
                if idx >= k
                    break
                end
            end
        end
        assert(idx <= k); %<HINT>
        if k == 1
            if idx == 0
                if isRow
                    i = zeros(1,0);
                else
                    i = zeros(0,1);
                end
            end
        else
            i = i(1:idx);
        end
    else
        for ii = nx:-1:1
            if (islogical(x) && x(ii)) || (~islogical(x) && x(ii) ~= xZERO)
                idx = idx + 1;
                i(idx) = ii;
                if idx >= k
                    break
                end
            end
        end
        assert(idx <= k); %<HINT>
        if k == 1
            if idx == 0
                if isRow
                    i = zeros(1,0);
                else
                    i = zeros(0,1);
                end
            end
        else
            i = i(1:idx);
            i = flipv(i);
        end
    end
end

%--------------------------------------------------------------------------

function x = flipv(x)
% Does FLIPLR on row vectors, FLIPUD on column vectors.
eml_allow_enum_inputs;
n = cast(eml_numel(x),eml_index_class);
nd2 = eml_index_rdivide(n,2);
for j = 1:nd2
    xtmp = x(j);
    x(j) = x(eml_index_plus(eml_index_minus(n,j),1));
    x(eml_index_plus(eml_index_minus(n,j),1)) = xtmp;
end

%--------------------------------------------------------------------------
