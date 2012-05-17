function [c,ia,ib] = eml_setop(op,a,b,varargin)
%Embedded MATLAB Library Function

%   Shared implementation for INTERSECT, SETDIFF, SETXOR, and UNION.
%
%   Notes:
%   1. When 'rows' is not specified:
%       Inputs must be row vectors. If a vector is variable-size, its first
%       dimension must have a fixed length of 1. The input [] is not
%       supported. Use a 1-by-0 input (e.g., zeros(1,0)) to represent the
%       empty set.  Empty outputs are always row vectors, 1-by-0, never
%       0-by-0.
%   2. When 'rows' is specified:
%       Outputs IA and IB are always column vectors, 0-by-1 if empty, never
%       0-by-0, even if the output C is 0-by-0.
%   3. Inputs must already be sorted in ascending order. The first output
%       will always be sorted in ascending order.
%   4. Complex inputs must be 'single' or 'double'.

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_assert(nargin >= 3, 'Not enough input arguments.');
eml_assert(nargin <= 4, 'Too many input arguments.');
eml_assert(eml_is_const(op) && ischar(op), ...
    'First input must be a constant operation string.');
eml_assert( ...
    (isa(a,'float') || isreal(a)) && ...
    (isa(b,'float') || isreal(b)), ...
    'Complex inputs must be ''single'' or ''double''.');
eml_assert((~eml.isenum(a) && ~eml.isenum(b)) || isa(a,class(b)), ...
    'The first two inputs must belong to the same enumeration class.');
if strcmp(op,'intersect')
    opcode = INTERSECT;
elseif strcmp(op,'setdiff')
    opcode = SETDIFF;
elseif strcmp(op,'setxor')
    opcode = SETXOR;
elseif strcmp(op,'union')
    opcode = UNION;
else
    eml_assert(false, ...
        'OP must be ''intersect'', ''setdiff'', ''setxor'', or ''union''.');
end
eml_assert( ...
    (isa(a,'numeric') || ischar(a) || islogical(a)) && ...
    (isa(b,'numeric') || ischar(b) || islogical(b)), ...
    'Inputs must be numeric, logical, or char.');
if nargin > 3
    flag = varargin{1};
    eml_assert(ischar(flag) && strcmp(eml_tolower(flag),'rows'), ...
        'Unknown flag.');
    [c,ia,ib] = do_rows(opcode,a,b);
else
    [c,ia,ib] = do_vectors(opcode,a,b);
end

%--------------------------------------------------------------------------

function [c,ia,ib] = do_vectors(opcode,a,b)
% Union of the vectors A and B.
eml_must_inline;
eml_allow_enum_inputs;
ZERO = zeros(eml_index_class);
ONE = ones(eml_index_class);
na = cast(eml_numel(a),eml_index_class);
nb = cast(eml_numel(b),eml_index_class);
% We intentionally leave in the much of the logic required to handle [],
% column vectors, and vector inputs with different orientations. In future
% we may have consistent behavior to match and also be able to support it
% efficiently, at which time the extra code will provide a convenient
% starting point. Currently, the compiler will constant-fold isCol and
% elide the extra code.
isNullA = false; % isequal(a,[]);
isNullB = false; % isequal(b,[]);
isVectorA = eml_is_const(isvector(a)) && isvector(a);
isVectorB = eml_is_const(isvector(b)) && isvector(b);
isScalarA = eml_is_const(isscalar(a)) && isscalar(a);
isScalarB = eml_is_const(isscalar(b)) && isscalar(b);
isColA = eml_is_const(size(a,2)) && size(a,2) == 1 && ~isScalarA;
isColB = eml_is_const(size(b,2)) && size(b,2) == 1 && ~isScalarB;
eml_assert(isVectorA && ~isColA && isVectorB && ~isColB, ...
    ['Unless ''rows'' is specified, inputs must be row vectors. ', ...
    'For variable-size inputs, the first dimension must have a ', ...
    'constant length of 1. The input [] is not supported. Use ', ...
    'a 1-by-0 input (e.g., zeros(1,0)) to represent the empty set.']);
if opcode == INTERSECT
    CZERO = eml_scalar_eg([eml_scalar_eg(a),eml_scalar_eg(b)]);
    ncmax = min(na,nb);
    niamax = ncmax;
    nibmax = ncmax;
elseif opcode == SETDIFF
    CZERO = eml_scalar_eg(a);
    ncmax = na;
    niamax = na;
    nibmax = ZERO;
else % opcode == SETXOR || opcode == UNION
    CZERO = eml_scalar_eg([eml_scalar_eg(a),eml_scalar_eg(b)]);
    ncmax = eml_index_plus(na,nb);
    niamax = na;
    nibmax = nb;
end
if opcode == SETDIFF
    isCol = isColA || ((isScalarA || isNullA) && isColB);
else
    isCol = ...
        (isColA && isColB) || ...
        (isColA && (isScalarB || isNullB)) || ...
        (isColB && (isScalarA || isNullA));
end
if eml_const(isCol)
    eml.varsize('c','ia','ib',[],[1,0]);
    c = eml.nullcopy(eml_expand(CZERO,[ncmax,1]));
    ia = eml.nullcopy(zeros(niamax,1));
else
    eml.varsize('c','ia','ib',[],[0,1]);
    c = eml.nullcopy(eml_expand(CZERO,[1,ncmax]));
    ia = eml.nullcopy(zeros(1,niamax));
end
nc = ZERO;
nia = ZERO;
if isCol
    ib = eml.nullcopy(zeros(nibmax,1));
else
    ib = eml.nullcopy(zeros(1,nibmax));
end
nib = ZERO;
if ~issorted(a)
    eml_error('EmbeddedMATLAB:eml_setop:unsortedA', ...
        'The first operand is not sorted in ascending order. Use SORT first.');
end
if ~issorted(b)
    eml_error('EmbeddedMATLAB:eml_setop:unsortedB', ...
        'The second operand is not sorted in ascending order. Use SORT first.');
end
i1 = ONE;
i2 = ONE;
while i1 <= na && i2 <= nb
    ak = a((i1));
    % Skip forward to the last instance of this value of ak.
    while i1 < na
        if eml_safe_eq(a((eml_index_plus(i1,1))),ak)
            i1 = eml_index_plus(i1,1);
        else
            break
        end
    end
    bk = b((i2));
    % Skip forward to the last instance of this value of bk.
    while i2 < nb
        if eml_safe_eq(b((eml_index_plus(i2,1))),bk)
            i2 = eml_index_plus(i2,1);
        else
            break
        end
    end
    if eml_safe_eq(ak,bk)
        if opcode == INTERSECT
            nc = eml_index_plus(nc,1);
            c(nc) = ak;
            ia(nc) = (i1);
            ib(nc) = (i2);
        elseif opcode == UNION
            nc = eml_index_plus(nc,1);
            c(nc) = ak;
            % MATLAB UNION does not note when elements of A are also in B.
            % nia = eml_index_plus(nia,1);
            % ia(nia) = (i1);
            nib = eml_index_plus(nib,1);
            ib(nib) = (i2);
        end
        i1 = eml_index_plus(i1,1);
        i2 = eml_index_plus(i2,1);
    elseif sort_lt(ak,bk) % ak < bk
        if opcode == SETDIFF || opcode == SETXOR || opcode == UNION
            nc = eml_index_plus(nc,1);
            c(nc) = ak;
            nia = eml_index_plus(nia,1);
            ia(nia) = (i1);
        end
        i1 = eml_index_plus(i1,1);
    else
        if opcode == SETXOR
            nc = eml_index_plus(nc,1);
            c(nc) = bk;
            nib = eml_index_plus(nib,1);
            ib(nib) = (i2);
        elseif opcode == UNION
            nc = eml_index_plus(nc,1);
            c(nc) = bk;
            nib = eml_index_plus(nib,1);
            ib(nib) = (i2);
        end
        i2 = eml_index_plus(i2,1);
    end
end
if opcode == SETDIFF || opcode == SETXOR || opcode == UNION
    % Remaining elements of A are not present in B.
    while i1 <= na
        ak = a((i1));
        while i1 < na
            if eml_safe_eq(a((eml_index_plus(i1,1))),ak)
                i1 = eml_index_plus(i1,1);
            else
                break
            end
        end
        nc = eml_index_plus(nc,1);
        c(nc) = ak;
        nia = eml_index_plus(nia,1);
        ia(nia) = (i1);
        i1 = eml_index_plus(i1,1);
    end
end
if opcode == SETXOR || opcode == UNION
    % Remaining elements of B are not present in A.
    while i2 <= nb
        bk = b((i2));
        while i2 < nb
            if eml_safe_eq(b((eml_index_plus(i2,1))),bk)
                i2 = eml_index_plus(i2,1);
            else
                break
            end
        end
        nc = eml_index_plus(nc,1);
        c(nc) = bk;
        nib = eml_index_plus(nib,1);
        ib(nib) = (i2);
        i2 = eml_index_plus(i2,1);
    end
end
if opcode == INTERSECT
    nia = nc;
    nib = nc;
end
% Trim the output arrays.
if ncmax > 0
    assert(nc <= ncmax); %<HINT>
    if isCol
        c = c(1:nc,1);
    else
        c = c(1,1:nc);
    end
end
if niamax > 0
    assert(nia <= niamax); %<HINT>
    if isCol
        ia = ia(1:nia,1);
    else
        ia = ia(1,1:nia);
    end
end
if opcode == INTERSECT || opcode == SETXOR || opcode == UNION
    if nibmax > 0
        assert(nib <= nibmax); %<HINT>
        if isCol
            ib = ib(1:nib,1);
        else
            ib = ib(1,1:nib);
        end
    end
end

%--------------------------------------------------------------------------

function p = sort_lt(a,b)
% Comparison function used in ordinary sorting.  Returns true if A is
% "less than" B, otherwise false.  Since this function is inlined, if A or
% B is stored in a register, it is possible that this routine returns true
% when an input is a float and EML_SAFE_EQ(A,B) returns true.
eml_allow_enum_inputs;
eml_must_inline;
if isreal(a) && isreal(b)
    p = a < b || isnan(b);
else
    absa = eml_scalar_abs(a);
    absb = eml_scalar_abs(b);
    absa_eq_absb = eml_safe_eq(absa,absb);
    p = (~absa_eq_absb && absa < absb) || isnan(absb) || ...
        (absa_eq_absb && eml_scalar_angle(a) < eml_scalar_angle(b));
end

%--------------------------------------------------------------------------

function p = relop_rows(a,arow,b,brow)
% Returns ROWS_ARE_EQUAL if a(arow,:) is equal to b(brow,:).
% Returns ROW_LESS_THAN if a(arow,:) is less than b(brow,:) in sorted order.
% Returns ROW_GREATER_THAN if a(arow,:) is greater than b(brow,:) in sorted
% order.
eml_allow_enum_inputs;
if ischar(a) && ischar(b)
    for k = ones(eml_index_class):min(size(a,2),size(b,2))
        if eml_safe_eq(a(arow,k),b(brow,k))
        elseif sort_lt(a(arow,k),b(brow,k))
            p = ROW_LESS_THAN;
            return
        else
            p = ROW_GREATER_THAN;
            return
        end
    end
    for k = eml_index_plus(size(b,2),1):size(a,2)
        if a(arow,k) ~= ' '
            p = ROW_GREATER_THAN;
            return
        end
    end
    for k = eml_index_plus(size(a,2),1):size(b,2)
        if b(brow,k) ~= ' '
            p = ROW_LESS_THAN;
            return
        end
    end
else
    for k = ones(eml_index_class):size(a,2)
        if eml_safe_eq(a(arow,k),b(brow,k))
        elseif sort_lt(a(arow,k),b(brow,k))
            p = ROW_LESS_THAN;
            return
        else
            p = ROW_GREATER_THAN;
            return
        end
    end
end
p = ROWS_ARE_EQUAL;

%--------------------------------------------------------------------------

function [c,ia,ib] = do_rows(opcode,a,b)
% Union of the rows of matrices A and B.
eml_must_inline;
eml_allow_enum_inputs;
ZERO = zeros(eml_index_class);
ONE = ones(eml_index_class);
eml_assert(ndims(a) == 2 && ndims(b) == 2, 'Inputs must be 2-D.');
charinput = ischar(a) && ischar(b);
eml_lib_assert(charinput || size(a,2) == size(b,2), ...
    'MATLAB:setxor:AandBColnumAgree', ...
    'A and B must have the same number of columns.');
na = cast(size(a,1),eml_index_class);
nacols = cast(size(a,2),eml_index_class);
nb = cast(size(b,1),eml_index_class);
nbcols = cast(size(b,2),eml_index_class);
mincols = min(nacols,nbcols);
if opcode == INTERSECT
    CZERO = eml_scalar_eg([eml_scalar_eg(a),eml_scalar_eg(b)]);
    ncmax = min(na,nb);
    niamax = ncmax;
    nibmax = ncmax;
    ccols = mincols;
elseif opcode == SETDIFF
    CZERO = eml_scalar_eg(a);
    ncmax = na;
    niamax = na;
    nibmax = ZERO;
    ccols = nacols;
else % opcode == SETXOR || opcode == UNION
    CZERO = eml_scalar_eg([eml_scalar_eg(a),eml_scalar_eg(b)]);
    ncmax = eml_index_plus(na,nb);
    niamax = na;
    nibmax = nb;
    if opcode == UNION
        ccols = max(nacols,nbcols);
    else
        ccols = mincols;
    end
end
if charinput
    eml.varsize('c',[],[1,1]);
else
    constncols = eml_is_const(nacols) && eml_is_const(nbcols);
    eml.varsize('c',[],[1,~constncols]);
end
eml.varsize('ia','ib',[],[1,0]);
c = eml.nullcopy(eml_expand(CZERO,[ncmax,ccols]));
if charinput
    c(:) = ' ';
end
nc = ZERO;
ia = eml.nullcopy(zeros(niamax,1));
nia = ZERO;
ib = eml.nullcopy(zeros(nibmax,1));
nib = ZERO;
if ~issorted(a,'rows')
    eml_error('EmbeddedMATLAB:eml_setop:unsortedA', ...
        'The first operand is not sorted in ascending order. Use SORTROWS first.');
end
if ~issorted(b,'rows')
    eml_error('EmbeddedMATLAB:eml_setop:unsortedB', ...
        'The second operand is not sorted in ascending order. Use SORTROWS first.');
end
i1 = ONE;
i2 = ONE;
while i1 <= na && i2 <= nb
    % Skip forward to the last instance of this value of ak.
    while i1 < na
        r = relop_rows(a,(eml_index_plus(i1,1)),a,(i1));
        if r == ROWS_ARE_EQUAL
            i1 = eml_index_plus(i1,1);
        else
            break
        end
    end
    % Skip forward to the last instance of this value of bk.
    while i2 < nb
        r = relop_rows(b,(eml_index_plus(i2,1)),b,(i2));
        if r == ROWS_ARE_EQUAL
            i2 = eml_index_plus(i2,1);
        else
            break
        end
    end
    r = relop_rows(a,(i1),b,(i2));
    if r == ROWS_ARE_EQUAL
        if opcode == INTERSECT
            nc = eml_index_plus(nc,1);
            for k = 1:nacols
                c(nc,k) = a((i1),k);
            end
            ia(nc) = (i1);
            ib(nc) = (i2);
        elseif opcode == UNION
            nc = eml_index_plus(nc,1);
            for k = 1:nacols
                c(nc,k) = a((i1),k);
            end
            % MATLAB UNION does not note when elements of A are also in B.
            % nia = eml_index_plus(nia,1);
            % ia(nia) = (i1);
            nib = eml_index_plus(nib,1);
            ib(nib) = (i2);
        end
        i1 = eml_index_plus(i1,1);
        i2 = eml_index_plus(i2,1);
    elseif r == ROW_LESS_THAN
        if opcode == SETDIFF || opcode == SETXOR || opcode == UNION
            nc = eml_index_plus(nc,1);
            for k = 1:nacols
                c(nc,k) = a((i1),k);
            end
            nia = eml_index_plus(nia,1);
            ia(nia) = (i1);
        end
        i1 = eml_index_plus(i1,1);
    else
        if opcode == SETXOR
            nc = eml_index_plus(nc,1);
            for k = 1:nbcols
                c(nc,k) = b((i2),k);
            end
            nib = eml_index_plus(nib,1);
            ib(nib) = (i2);
        elseif opcode == UNION
            nc = eml_index_plus(nc,1);
            for k = 1:nbcols
                c(nc,k) = b((i2),k);
            end
            nib = eml_index_plus(nib,1);
            ib(nib) = (i2);
        end
        i2 = eml_index_plus(i2,1);
    end
end
if opcode == SETDIFF || opcode == SETXOR || opcode == UNION
    % Remaining rows of A are not present in B.
    while i1 <= na
        while i1 < na
            r = relop_rows(a,(eml_index_plus(i1,1)),a,(i1));
            if r == ROWS_ARE_EQUAL
                i1 = eml_index_plus(i1,1);
            else
                break
            end
        end
        nc = eml_index_plus(nc,1);
        for k = 1:nacols
            c(nc,k) = a((i1),k);
        end
        nia = eml_index_plus(nia,1);
        ia(nia) = (i1);
        i1 = eml_index_plus(i1,1);
    end
end
if opcode == SETXOR || opcode == UNION
    % Remaining elements of B are not present in A.
    while i2 <= nb
        while i2 < nb
            r = relop_rows(b,(eml_index_plus(i2,1)),b,(i2));
            if r == ROWS_ARE_EQUAL
                i2 = eml_index_plus(i2,1);
            else
                break
            end
        end
        nc = eml_index_plus(nc,1);
        for k = 1:nbcols
            c(nc,k) = b((i2),k);
        end
        nib = eml_index_plus(nib,1);
        ib(nib) = (i2);
        i2 = eml_index_plus(i2,1);
    end
end
assert(nc <= ncmax); %<HINT>
if charinput && ...
        (opcode == INTERSECT || opcode == SETDIFF || opcode == SETXOR)
    % Trim trailing columns if they are all spaces.
    col = ccols;
    while col >= 1
        if col_is_all_spaces(c,nc,col)
            col = eml_index_minus(col,1);
        else
            break
        end
    end
    assert(col <= ccols)
    c = c(1:nc,1:col);
else
    c = c(1:nc,:);
end
if opcode == INTERSECT
    nia = nc;
    nib = nc;
end
assert(nia <= niamax); %<HINT>
ia = ia(1:nia,1);
if opcode == INTERSECT || opcode == SETXOR || opcode == UNION
    assert(nib <= nibmax); %<HINT>
    ib = ib(1:nib,1);
end

%--------------------------------------------------------------------------

function p = col_is_all_spaces(c,nrows,col)
eml_must_inline;
eml_allow_enum_inputs;
for k = 1:nrows
    if c(k,col) ~= ' '
        p = false;
        return
    end
end
p = true;

%--------------------------------------------------------------------------

function y = ROWS_ARE_EQUAL
eml_must_inline;
y = uint8(0);

function y = ROW_LESS_THAN
eml_must_inline;
y = uint8(1);

function y = ROW_GREATER_THAN
eml_must_inline;
y = uint8(2);

%--------------------------------------------------------------------------

function y = INTERSECT
eml_must_inline;
y = uint8(1);

function y = SETDIFF
eml_must_inline;
y = uint8(2);

function y = SETXOR
eml_must_inline;
y = uint8(3);

function y = UNION
eml_must_inline;
y = uint8(4);

%--------------------------------------------------------------------------
