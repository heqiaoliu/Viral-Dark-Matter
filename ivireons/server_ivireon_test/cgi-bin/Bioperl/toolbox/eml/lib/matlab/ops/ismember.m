function [tf,loc] = ismember(a,s,flag)
%Embedded MATLAB Library Function

%   1. The second input, S, must be sorted in ascending order.
%   2. Complex inputs must be 'single' or 'double'.

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_assert(nargin >= 2, 'Not enough input arguments.');
eml_assert(nargin <= 3, 'Too many input arguments.');
eml_assert((~eml.isenum(a) && ~eml.isenum(s)) || isa(a,class(s)), ...
    'The first two inputs must belong to the same enumeration class.');
eml_assert( ...
    (isa(a,'numeric') || ischar(a) || islogical(a)) && ...
    (isa(s,'numeric') || ischar(s) || islogical(s)), ...
    'Inputs must be numeric, logical, or char.');
eml_assert( ...
    (isa(a,'float') || isreal(a)) && ...
    (isa(s,'float') || isreal(s)), ...
    'Complex inputs must be ''single'' or ''double''.');
if nargin == 3
    eml_assert(ischar(flag) && strcmp(eml_tolower(flag),'rows'), ...
        'Unknown flag.');
    eml_assert(ndims(a) == 2 && ndims(s) == 2, 'Inputs must be 2-D.');
    rowsA = cast(size(a,1),eml_index_class);
    colsA = cast(size(a,2),eml_index_class);
    rowsS = cast(size(s,1),eml_index_class);
    colsS = cast(size(s,2),eml_index_class);
    tf = false(size(a,1),1);
    loc = zeros(size(a,1),1);
    nc = min(colsA,colsS);
    charinput = ischar(a) && ischar(s);
    eml_lib_assert(charinput || colsA == colsS, ...
        'MATLAB:ISMEMBER:AandBColnumAgree', ...
        'A and B must have the same number of columns.');
    % For now we keep this case simple. It's an O(m*m*n) algorithm without
    % the binary search. If we add the binary search we can reduce it to
    % O(m*log2(m)*n). Even though the current algorithm doesn't require it,
    % we ask that S already be sorted so that we may upgrade the algorithm
    % in future without introducing a backward incompatibility.
    if ~issorted(s,'rows')
        eml_error('EmbeddedMATLAB:ismember:unsortedS', ...
            'The second operand is not sorted in ascending order. Use SORTROWS first.');
    end
    for k = 1:rowsA
        tf(k) = false;
        loc(k) = 0;
        for i = rowsS:-1:1
            rowmatch = true;
            for j = 1:nc
                if ~eml_safe_eq(a(k,j),s(i,j))
                    rowmatch = false;
                    break
                end
            end
            if charinput && rowmatch
                if colsA > colsS
                    for j = eml_index_plus(colsS,1):colsA
                        if a(k,j) ~= ' '
                            rowmatch = false;
                            break
                        end
                    end
                else
                    for j = eml_index_plus(colsA,1):colsS
                        if s(i,j) ~= ' '
                            rowmatch = false;
                            break
                        end
                    end
                end
            end
            if rowmatch
                tf(k) = true;
                loc(k) = i;
                break
            end
        end
    end
else
    if ~issorted(s(:))
        eml_error('EmbeddedMATLAB:ismember:unsortedS', ...
            'The second operand is not sorted in ascending order. Use SORT first.');
    end
    na = cast(eml_numel(a),eml_index_class);
    tf = false(size(a));
    loc = zeros(size(a));
    % Since we require that the inputs are already sorted, we don't need
    % the following case for efficiency.
    % ns = cast(eml_numel(s),eml_index_class);
    % if na <= 5
    %     % Use linear search.
    %     for k = 1:na
    %         for j = ns:-1:1
    %             if eml_safe_eq(a(k),s(j))
    %                 tf(k) = true;
    %                 loc(k) = j;
    %                 break
    %             end
    %         end
    %     end
    % else
    % Use binary search.
    for k = 1:na
        n = bsearch(a(k),s);
        if n > 0
            tf(k) = true;
            loc(k) = n;
        end
    end
end

%--------------------------------------------------------------------------

function idx = bsearch(x,s)
% Binary search to find the largest idx such that x == s(idx).
% Returns zero if no match exists.
eml_allow_enum_inputs;
ns = cast(eml_numel(s),eml_index_class);
idx = zeros(eml_index_class);
ucls = eml_unsigned_class(eml_index_class);
UONE = ones(ucls);
ilo = UONE;
ihi = cast(ns,ucls);
while ihi >= ilo
    % Avoid overflow in computation of imid.  Computes imid by
    % ilo>>1 + ihi>>1 and subsequently adding 1 to the result if
    % ilo and ihi are both odd.
    imid = eml_plus(eml_rshift(ilo,UONE),eml_rshift(ihi,UONE),ucls,'spill');
    if (eml_bitand(ilo,UONE) == UONE) && (eml_bitand(ihi,UONE) == UONE)
        imid = eml_plus(imid,UONE,ucls,'spill');
    end
    if eml_safe_eq(x,s(imid))
        idx = cast(imid,eml_index_class);
        break
    end
    if sort_lt(x,s(imid))
        ihi = eml_minus(imid,UONE,ucls,'spill');
    else
        ilo = eml_plus(imid,UONE,ucls,'spill');
    end
end
if idx > 0
    % We've matched an element exactly, but we need to scan forward to
    % the larges idx such that x == s(idx).
    idx = eml_index_plus(idx,1);
    while idx <= ns && eml_safe_eq(x,s(idx))
        idx = eml_index_plus(idx,1);
    end
    idx = eml_index_minus(idx,1);
end

%--------------------------------------------------------------------------

function p = sort_lt(a,b)
% Comparison function used in ordinary sorting.  Returns true if A is
% "less than" B, otherwise false.  Since this function is inlined, if A or
% B is stored in a register, it is possible that this routine returns true
% when an input is a float and EML_SAFE_EQ(A,B) returns true.
eml_allow_enum_inputs;
eml_must_inline;
if eml_const(isreal(a) && isreal(b))
    p = a < b || isnan(b);
else
    absa = eml_scalar_abs(a);
    absb = eml_scalar_abs(b);
    absa_eq_absb = eml_safe_eq(absa,absb);
    p = (~absa_eq_absb && absa < absb) || isnan(absb) || ...
        (absa_eq_absb && eml_scalar_angle(a) < eml_scalar_angle(b));
end

%--------------------------------------------------------------------------
