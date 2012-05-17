function p = eml_sort_le(v,col,irow1,irow2)
%Embedded MATLAB Private Function

%   SORTROWS "less than or equal to" comparison function.  For vector
%   sorting, use col = 'a' for ascending or col = 'd' for descending.

%   Copyright 2004-2010 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_prefer_const(col);
if ischar(col)
    % Vector sorting.
    if isreal(v)
        eml_must_inline;
    end
    if col == 'd'
        p = eml_sort_descending_le(v(irow1),v(irow2));
    else
        p = eml_sort_ascending_le(v(irow1),v(irow2));
    end
else
    % Matrix sorting (SORTROWS).
    p = true;
    for k = 1:eml_numel(col)
        colk = col(k);
        abscolk = cast(eml_scalar_abs(colk),eml_index_class);
        coloffset = eml_index_times(eml_index_minus(abscolk,1),size(v,1));
        v1 = v(eml_index_plus(coloffset,irow1));
        v2 = v(eml_index_plus(coloffset,irow2));
        if ~(v1 == v2 || (isnan(v1) && isnan(v2)))
            if colk < 0
                p = eml_sort_descending_le(v1,v2);
            else
                p = eml_sort_ascending_le(v1,v2);
            end
            return
        end
    end
end

%--------------------------------------------------------------------------

function p = eml_sort_ascending_le(a,b)
% Comparison function used in ordinary sorting.  Returns true if A is
% "less than or equal to" B in the sorted order, otherwise false.
eml_allow_enum_inputs;
eml_must_inline;
if eml_const(isreal(a) && isreal(b))
    p = a <= b || isnan(b);
elseif a == b 
    %> Above are intentional floating point equality comparisons. This case
    %> is required to guarantee sort stability when comparing angle(a) <=
    %> angle(b) below if the target compiler computes and stores one of
    %> those angles in an extended precision register.
    p = true;
else
    % Since absa and absb are computed here, rather than indexed from an
    % array, there is a risk of indeterminacy. We use eml_safe_eq to
    % prevent it.
    absa = eml_scalar_abs(a);
    absb = eml_scalar_abs(b);
    if eml_safe_eq(absa,absb)
        absa = eml_scalar_angle(a);
        absb = eml_scalar_angle(b);
    end
    p = eml_sort_ascending_le(absa,absb);
end

%--------------------------------------------------------------------------

function p = eml_sort_descending_le(a,b)
% Comparison function used in ordinary sorting.  Returns true if A is
% "greater than or equal to" B in the sorted order, otherwise false.
eml_allow_enum_inputs;
eml_must_inline;
if eml_const(isreal(a) && isreal(b))
    p = a >= b || isnan(a);
elseif a == b 
    %> Above are intentional floating point equality comparisons. This case
    %> is required to guarantee sort stability when comparing angle(a) >=
    %> angle(b) below if the target compiler computes and stores one of
    %> those angles in an extended precision register.
    p = true;
else
    % Since absa and absb are computed here, rather than indexed from an
    % array, there is a risk of indeterminacy. We use eml_safe_eq to
    % prevent it.
    absa = eml_scalar_abs(a);
    absb = eml_scalar_abs(b);
    if eml_safe_eq(absa,absb)
        absa = eml_scalar_angle(a);
        absb = eml_scalar_angle(b);
    end
    p = eml_sort_descending_le(absa,absb);
end

%--------------------------------------------------------------------------
