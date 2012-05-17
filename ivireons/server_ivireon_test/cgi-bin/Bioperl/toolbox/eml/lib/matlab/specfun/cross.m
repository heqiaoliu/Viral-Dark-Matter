function c = cross(a,b,dim)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Input argument "A" is undefined.');
eml_assert(nargin > 1, 'Input argument "B" is undefined.');
if nargin == 3
    eml_prefer_const(dim);
    eml_assert_valid_dim(dim);
    eml_lib_assert(size(a,dim) == 3 && size(b,dim) == 3, ...
        'MATLAB:cross:InvalidDimAorBForCrossProd', ...
        ['A and B must be of length 3 in the dimension in which the ', ...
        'cross product is taken.']);
end
eml_assert(isa(a,'float') && isa(b,'float'), ...
    'Unsupported input class.  Must be single or double.');
if eml_is_const(isvector(a) && isvector(b)) && isvector(a) && isvector(b)
    eml_lib_assert(eml_numel(a) == 3 && eml_numel(b) == 3, ...
        'MATLAB:cross:InputSizeMismatch', ...
        'A and B must be same size.');
    % Quick processing for the usual case.
    c1 = a(2)*b(3) - a(3)*b(2);
    c2 = a(3)*b(1) - a(1)*b(3);
    c3 = a(1)*b(2) - a(2)*b(1);
    if eml_is_const(size(a,2)) && size(a,2) == 1 && ...
            eml_is_const(size(b,2)) && size(b,2) == 1
        c = [c1; c2; c3];
    else
        c = [c1, c2, c3];
    end
else
    eml_lib_assert(isequal(size(a),size(b)), ...
        'MATLAB:cross:InputSizeMismatch', ...
        'A and B must be same size.');
    c = eml.nullcopy(eml_expand(eml_scalar_eg(a,b),size(a)));
    if isempty(a)
        return
    end
    ONE = ones(eml_index_class);
    ZERO = zeros(eml_index_class);
    if nargin < 3
        dim = findDim3(a);
        eml_lib_assert(dim >= 1, ...
            'MATLAB:cross:InvalidDimAorB', ...
            'A and B must have at least one dimension of length 3.');
    end
    eml_lib_assert(~(isvector(a) && isvector(b)) || ...
        isequal(size(a),size(b)), ...
        'EmbeddedMATLAB:variableSizeMatrixToVector', ...
        ['Variable-size array inputs that become vectors at run-time ', ...
        'must have the same orientation.']);
    if dim >= 2
        stride = eml_matrix_vstride(a,dim);
        stridem1 = eml_index_minus(stride,ONE);
    else
        stride = ONE;
        stridem1 = ZERO;
    end
    iNext = eml_index_times(stride,3);
    if dim >= ndims(a)
        nHigh = ONE;
    else
        nHigh = eml_index_plus(1, ...
            eml_index_times(iNext, ...
            eml_index_minus(eml_matrix_npages(a,dim),1)));
    end
    for iStart = ONE:iNext:nHigh
        iEnd = eml_index_plus(iStart,stridem1);
        for i1 = iStart:iEnd
            i2 = eml_index_plus(i1,stride);
            i3 = eml_index_plus(i2,stride);
            % Calculate cross product
            c(i1) = a(i2)*b(i3) - a(i3)*b(i2);
            c(i2) = a(i3)*b(i1) - a(i1)*b(i3);
            c(i3) = a(i1)*b(i2) - a(i2)*b(i1);
        end
    end
end

%--------------------------------------------------------------------------

function k = findDim3(x)
% Find the index of the first value 3 in the vector size(x).
k = zeros(eml_index_class);
for m = ones(eml_index_class):ndims(x)
    if size(x,m) == 3
        k = m;
        break
    end
end

%--------------------------------------------------------------------------
