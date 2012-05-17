function [y,ndx] = sortrows(y,col)
%Embedded MATLAB Library Function

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(y,'numeric') || ischar(y) || islogical(y), ...
    ['Function ''sortrows'' is not defined for values of class ''' class(y) '''.']);
eml_assert(isreal(y) || isa(y,'float'), ...
    'Complex inputs to SORTROWS must be ''double'' or ''single''.');
eml_lib_assert(ndims(y) == 2, ...
    'MATLAB:SORTROWS:inputDimensionMismatch', ...
    'X must be a 2-D matrix.');
ONE = ones(eml_index_class);
m = size(y,1);
n = cast(size(y,2),eml_index_class);
ndx = eml.nullcopy(zeros(m,1));
if nargin == 1
    col = eml.nullcopy(zeros(1,n,eml_index_class));
    for k = ONE:n
        col(k) = k;
    end
    idx = eml_sort_idx(y,col);
    y = apply_row_permutation(y,idx);
    for k = ONE:m
        ndx(k) = idx(k);
    end
else
    eml_prefer_const(col);
    eml_assert(~eml.isenum(col), 'Enumerations are not supported for COL input.');
    eml_assert(isa(col,'numeric'), 'COL must be numeric.');
    if eml_is_const(size(col)) && isequal(col,[])
        for k = ONE:m
            ndx(k) = k;
        end
    else
        eml_lib_assert(isreal(col) && isvector(col) && col_in_range(col,n), ...
            'MATLAB:sortrows:COLmismatchX', ...
            'COL must be a vector of column indices into X.');
        idx = eml_sort_idx(y,col);
        y = apply_row_permutation(y,idx);
        for k = ONE:m
            ndx(k) = idx(k);
        end
    end
end

%--------------------------------------------------------------------------

function y = apply_row_permutation(y,idx)
% Permute the rows of matrix Y using the permutation vector IDX.
eml_allow_enum_inputs;
m = cast(size(y,1),eml_index_class);
n = cast(size(y,2),eml_index_class);
ycol = eml.nullcopy(eml_expand(eml_scalar_eg(y),[m,1]));
for j = 1:n
    for i = 1:m
        ycol(i) = y(idx(i),j);
    end
    for i = 1:m
        y(i,j) = ycol(i);
    end
end

%--------------------------------------------------------------------------

function p = col_in_range(col,n)
% Return TRUE if all the elements of COL are integers between 1 and n,
% otherwise return FALSE.
for k = 1:eml_numel(col)
    ck = abs(col(k));
    if floor(ck) ~= ck || ck < 1 || ck > n
        p = false;
        return
    end
end
p = true;

%--------------------------------------------------------------------------
