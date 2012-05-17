function y = diff(x,n,dim)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(x,'numeric') || islogical(x) || ischar(x), ...
    'Input must be numeric, logical, or char.');
ONE = ones(eml_index_class);
if islogical(x) || ischar(x)
    xzero = 0;
else
    xzero = eml_scalar_eg(x);
end
if nargin < 2 || isempty(n)
    order = ones(eml_index_class);
else
    eml_prefer_const(n);
    eml_assert(eml_is_const(n) || eml_option('VariableSizing'), ...
        'N must be a constant.');
    order = cast(n,eml_index_class);
    eml_lib_assert(isscalar(n) && isreal(n) && n >= 1 && n == order, ...
        'MATLAB:diff:differenceOrderMustBePositiveInteger', ...
        ['Difference order N must be a positive integer scalar in ', ...
        'the range 1 to intmax(''' eml_index_class ''').']);
end
constsize = eml_is_const(size(x)) && eml_is_const(order);
if nargin < 3
    dim = eml_const_nonsingleton_dim(x);
    dimSize = size(x,dim);
    if dimSize == 0
        xSize = size(x);
        xSize(dim) = 0; % Turns out this is needed for tight bounds.
        y = eml_expand(xzero,xSize);
        return
    end
    orderForDim = min(eml_index_minus(dimSize,1),order);
    if orderForDim < 1
        y = eml_expand(xzero,[0,0]);
        return
    end
    eml_lib_assert(eml_is_const(dimSize) || dimSize ~= 1, ...
        'EmbeddedMATLAB:diff:autoDimIncompatibility', ...
        ['The working dimension was selected automatically, is ', ...
        'variable-length, and has length 1 at run-time. This is not ', ...
        'supported. Manually select the working dimension by ', ...
        'supplying the DIM argument.']);
else
    eml_prefer_const(dim);
    eml_assert(eml_is_const(dim), ...
        'Dimension argument must be a constant.');
    eml_assert_valid_dim(dim);
    if dim > eml_ndims(x)  % Matlab N-D behavior.
        idims = eml_index_minus(dim,eml_ndims(x)+1);
        y = eml_expand(xzero,[size(x),ones(1,idims),0]);
        return
    end
    dimSize = size(x,dim);
    if dimSize <= order
        xSize = size(x);
        xSize(dim) = 0;
        y = eml_expand(xzero,xSize);
        return
    end
    orderForDim = order;
end
eml_lib_assert(constsize || orderForDim == order, ...
    'EmbeddedMATLAB:diff:orderLimitForVariableSizedX', ...
    ['The length of the working dimension must be greater than the ', ...
    'difference order when the input is variably sized or the ', ...
    'difference order is not a constant.']);
newDimSize = eml_index_minus(dimSize,orderForDim);
ySize = size(x);
ySize(dim) = newDimSize;
work = eml.nullcopy(eml_expand(xzero,[orderForDim,ONE]));
y1 = eml.nullcopy(eml_expand(xzero,ySize));
stride = eml_size_prod(x,ONE,eml_index_minus(dim,1));
xNext = eml_index_times(stride,dimSize);
yNext = eml_index_times(stride,newDimSize);
nHigh = eml_size_prod(x,eml_index_plus(dim,1));
ixStart = ONE;
iyStart = ONE;
tmp1 = eml.nullcopy(xzero);
for r = ONE:nHigh
    ix = ixStart;
    iy = iyStart;
    for s = ONE:stride
        ixLead = eml_index_plus(ix,stride);
        iyLead = iy;
        work(1) = x(ix);
        if orderForDim >= 2
            for m = ONE:eml_index_minus(orderForDim,ONE)
                tmp1(1) = x(ixLead);
                for k = ONE:m
                    tmp2 = work(k);
                    work(k) = tmp1;
                    tmp1 = tmp1 - tmp2;
                end
                work(eml_index_plus(m,ONE)) = tmp1;
                ixLead = eml_index_plus(ixLead,stride);
            end
        end
        for m = eml_index_plus(orderForDim,ONE):dimSize
            tmp1(1) = x(ixLead);
            for k = ONE:orderForDim
                tmp2 = work(k);
                work(k) = tmp1;
                tmp1 = tmp1 - tmp2;
            end
            ixLead = eml_index_plus(ixLead,stride);
            y1(iyLead) = tmp1;
            iyLead = eml_index_plus(iyLead,stride);
        end
        ix = eml_index_plus(ix,ONE);
        iy = eml_index_plus(iy,ONE);
    end
    ixStart = eml_index_plus(ixStart,xNext);
    iyStart = eml_index_plus(iyStart,yNext);
end
if constsize && orderForDim < order
    % Diff along another dimension.
    n2 = eml_index_minus(order,orderForDim);
    y = diff(y1,n2);
else
    y = y1;
end
