function y = median(x,dim)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments');
eml_assert(isa(x,'float'), ['Function ''median'' is not defined for values of class ''' class(x) '''.']);
if nargin == 1
    if eml_is_const(size(x)) && isequal(x,[])
        % The output size for [] is a special case when DIM is not given.
        y = eml_guarded_nan(class(x));
        return
    end
    eml_lib_assert(eml_is_const(size(x)) || ~isequal(x,[]), ...
        'EmbeddedMATLAB:median:specialEmpty', ...
        'MEDIAN with one variable-size matrix input of [] is not supported.');
    dim = eml_const_nonsingleton_dim(x);
    eml_lib_assert(eml_is_const(size(x,dim)) || ...
        isscalar(x) || ...
        size(x,dim) ~= 1, ...
        'EmbeddedMATLAB:median:autoDimIncompatibility', ...
        ['The working dimension was selected automatically, is ', ...
        'variable-length, and has length 1 at run-time. This is not ', ...
        'supported. Manually select the working dimension by ', ...
        'supplying the DIM argument.']);
else
    eml_prefer_const(dim);
    eml_assert(eml_is_const(dim),'Dimension argument must be a constant.');
    eml_assert_valid_dim(dim);
end
if dim > eml_ndims(x)
    y = x;
    return
end
sz = size(x);
sz(dim) = 1;
y = eml.nullcopy(eml_expand(eml_scalar_eg(x),sz));
if isempty(x) || eml_ambiguous_types
    y(:) = eml_guarded_nan(class(x));
elseif eml_is_const(isscalar(y)) && isscalar(y)
    y(1) = vectormedian(x);
else
    vlen = size(x,dim);
    vwork = eml.nullcopy(eml_expand(eml_scalar_eg(x),[vlen,1]));
    vstride = eml_matrix_vstride(x,dim);
    vspread = eml_index_times(eml_index_minus(vlen,1),vstride);
    npages  = eml_matrix_npages(x,dim);
    i2 = zeros(eml_index_class);
    iy = zeros(eml_index_class);
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
            % Calculate median and store in y.
            iy = eml_index_plus(iy,1);
            y(iy) = vectormedian(vwork);
        end
    end
end

%--------------------------------------------------------------------------

function m = vectormedian(v)
% Median of a vector.
vlen = eml_numel(v);
midm1 = eml_index_rdivide(vlen,2);
mid = eml_index_plus(midm1,1);
evenlength = vlen == eml_index_times(midm1,2);
idx = eml_sort_idx(v,'a');
if isnan(v(idx(end)))
    m = v(idx(end));
elseif evenlength
    m = meanof(v(idx(midm1)),v(idx(mid)));
else
    m = v(idx(mid));
end

%--------------------------------------------------------------------------

function c = meanof(a,b)
% MEANOF the mean of scalar A and scalar B with B > A
%    MEANOF calculates the mean of A and B. It uses different formula
%    in order to avoid overflow in floating point arithmetic.
eml_must_inline;
if ((a < 0) ~= (b < 0)) ... % slightly better C code than when using SIGN.
        || isinf(a) || isinf(b)
    c = eml_div(a+b,2);
else
    c = a + eml_div(b-a,2);
end

%--------------------------------------------------------------------------
