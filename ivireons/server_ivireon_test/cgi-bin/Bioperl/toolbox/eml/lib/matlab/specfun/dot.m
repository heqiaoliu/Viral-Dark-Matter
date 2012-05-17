function c = dot(a,b,dim)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 1, 'Not enough input arguments.');
eml_assert(isa(a,'numeric') || ischar(a),...
    ['Function ''dot'' is not defined for values of A of class ''' class(a) '''.']);
eml_assert(isa(b,'numeric') || ischar(b),...
    ['Function ''dot'' is not defined for values of B of class ''' class(b) '''.']);
eml_lib_assert(isequal(size(a),size(b)) ||  ...
    (isvector(a) && isvector(b) && eml_numel(a) == eml_numel(b)),...
    'MATLAB:dot:InputSizeMismatch', ...
    'A and B must be same size.');
ONE = ones(eml_index_class);
if isfloat(a) && isfloat(b)
    zero_of_output_type = eml_scalar_eg(a,b);
else
    zero_of_output_type = eml_scalar_eg(double(a),double(b));
end
if nargin < 3
    if isvector(a)
        n = cast(eml_numel(a),eml_index_class);
        c = vdot(a,b,ONE,ONE,n,n);
        return
    elseif isequal(a,[])
        c = zero_of_output_type;
        return
    end
    dim = eml_nonsingleton_dim(a);
else
    eml_prefer_const(dim);
    eml_assert(eml_is_const(dim) || eml_option('VariableSizing'), ...
        'Dimension argument must be a constant.');
    eml_assert_valid_dim(dim);
end
if size(a,dim) == 1 % Covers dim > ndims case.
    sz = size(a);
    % This condition is designed to be always constant-folded.
    if eml_is_const(dim) && dim <= eml_ndims(a) 
        % This assignment tells inference that this dimension 
        % of the result is static 1. The assignment itself 
        % is removed by optimizations once its job is done.
        sz(dim) = 1; 
        c = eml.nullcopy(eml_expand(zero_of_output_type,sz));
    else 
        c = eml.nullcopy(eml_expand(zero_of_output_type,sz));
    end
    for j = ones(eml_index_class):eml_numel(c)
        c(j) = eml_conjtimes(a(j),b(j));
    end
    return
end 
sz = size(a);
sz(dim) = 1;
c = eml.nullcopy(eml_expand(zero_of_output_type,sz));
vlen = cast(size(a,dim),eml_index_class);
vstride = eml_matrix_vstride(a,dim);
vspread = eml_index_times(eml_index_minus(vlen,1),vstride);
npages = eml_matrix_npages(a,dim);
i2 = zeros(eml_index_class);
ic = zeros(eml_index_class);
for i = 1:npages
    i1 = i2;
    i2 = eml_index_plus(i2,vspread);
    for j = 1:vstride
        ic = eml_index_plus(ic,1);
        i1 = eml_index_plus(i1,1);
        i2 = eml_index_plus(i2,1);
        c(ic) = vdot(a,b,i1,vstride,i2,vlen);
    end
end

%--------------------------------------------------------------------------

function c = vdot(a,b,i1,stride,i2,n)
% Vector dot product:  c = dot(a(i1:stride:i2),b(i1:stride:i2)).
% Dispatches to BLAS for float inputs and does the equivalent of
% sum(conj(a).*b) for non-floats.  The argument n is mathematically
% redundant, given that n = 1 + (i2 - i1)/stride, but i1, stride, and n are
% needed when calling the BLAS with float inputs, while i1, stride, and i2
% are most convenient for handling non-float inputs.
eml_must_inline;
if isa(a,'float') && isa(b,'float')
    c = eml_xdotc(n,a,i1,stride,b,i1,stride);
else
    c = 0;
    for k = i1:stride:i2
        c = c + double(eml_conjtimes(a(k),b(k)));
    end
end

%--------------------------------------------------------------------------
