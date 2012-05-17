function [x,idx] = eml_sort(x,dim,mode)
%Embedded MATLAB Private Function

%   SORT function without error checking on the type of X.  Required
%   functions for the real case are LE for ascending, GE for descending,
%   and ISNAN. Additional required functions for the complex case are LT
%   for ascending, GT for descending, EML_SCALAR_ABS, EQ (real only), and
%   EML_SCALAR_ANGLE.

%   Copyright 2004-2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_assert(nargin > 0, 'Not enough input arguments.');
if nargin == 2 && ischar(dim)
    % The input argument DIM is the mode string.
    if nargout == 2
        [x,idx] = eml_sort(x,eml_nonsingleton_dim(x),dim);
    else
        % Although separating this case is not strictly necessary, it helps
        % the compiler eliminate the index vector idx.
        x = eml_sort(x,eml_nonsingleton_dim(x),dim);
    end
    return
end
ASCEND = 'a';
DESCEND = 'd';
% Validate optional arguments.
if nargin < 3
    sortdir = ASCEND;
    if nargin < 2
        dim = eml_nonsingleton_dim(x);
    end
else
    if ischar(mode) && strcmp(mode,'ascend')
        sortdir = ASCEND;
    elseif ischar(mode) && strcmp(mode,'descend')
        sortdir = DESCEND;
    else
        eml_assert(false,'Sorting direction must be ''ascend'' or ''descend''.');
    end
end
eml_prefer_const(dim);
eml_assert(eml_is_const(dim) || eml_option('VariableSizing'), ...
    'Dimension argument must be a constant.');
eml_assert_valid_dim(dim);
idx = ones(size(x));
vlen = size(x,dim);
vwork = eml.nullcopy(eml_expand(eml_scalar_eg(x),[vlen,1]));
if eml_is_const(isvector(x)) && isvector(x) && eml_is_const(dim) && ( ...
        (dim == 1 && eml_is_const(size(x,2)) && size(x,2) == 1) || ...
        (dim == 2 && eml_is_const(size(x,1)) && size(x,1) == 1))
    iidx = eml_sort_idx(x,sortdir);
    % Copy vectors into the output matrices.
    idx(:) = iidx(:);
    x(:) = x(iidx(:));
else
    vstride = eml_matrix_vstride(x,dim);
    vspread = eml_index_times(eml_index_minus(vlen,1),vstride);
    npages  = eml_matrix_npages(x,dim);
    i2 = zeros(eml_index_class);
    for i = 1:npages
        i1 = i2;
        i2 = eml_index_plus(i2,vspread);
        for j = 1:vstride
            i1 = eml_index_plus(i1,1);
            i2 = eml_index_plus(i2,1);
            % Copy x(i1:vstride:i2) to vwork.
            ix = i1;
            for k = 1:vlen
                vwork(k) = x(ix);
                ix = eml_index_plus(ix,vstride);
            end
            iidx = eml_sort_idx(vwork,sortdir);
            % Copy vectors into the output matrices.
            ix = i1;
            for k = 1:vlen
                x(ix) = vwork(iidx(k));
                idx(ix) = double(iidx(k));
                ix = eml_index_plus(ix,vstride);
            end
        end
    end
end
