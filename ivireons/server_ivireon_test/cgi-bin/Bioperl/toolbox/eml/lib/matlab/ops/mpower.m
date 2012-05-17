function c = mpower(a,b)
%Embedded MATLAB Library Function

%   Limitations:
%   1. char and logical inputs are not supported.
%   2. The result when A is a scalar and B is a matrix is always complex.
%   3. At least one argument must be complex when A is a matrix and B is a
%      non-integer scalar.

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 1, 'Not enough input arguments.');
eml_prefer_const(b);
eml_assert(isa(a,'numeric'), ...
    ['Function ''mpower'' is not defined for values of class ''' class(a) '''.']);
eml_assert(isa(b,'numeric'), ...
    ['Function ''mpower'' is not defined for values of class ''' class(b) '''.']);
if isinteger(a) || isinteger(b)
    eml_assert(isscalar(a) && isscalar(b), 'Both operands must be scalar.');
    eml_assert(isa(a,class(b)) || isa(a,'double') || isa(b,'double'), ...
        'Integers can only be combined with integers of the same class, or scalar doubles.');
end
eml_assert(isscalar(a) || isscalar(b), 'At least one operand must be scalar.');
eml_lib_assert(ndims(a) == 2 && ndims(b) == 2, ...
    'EmbeddedMATLAB:mpower:inputsMustBe2D', ...
    'Input arguments must be 2-D.');
eml_lib_assert(size(a,1) == size(a,2) && size(b,1) == size(b,2), ...
    'MATLAB:square', ...
    'Matrix must be square.');
if eml_is_const(size(a)) && isscalar(a) && ...
        eml_is_const(size(b)) && isscalar(b)
    c = a .^ b;
elseif eml_is_const(size(a)) && isscalar(a)
    c = scalar_to_matrix_power(a,b);
elseif isreal(b) && eml_scalar_floor(b) == b
    c = matrix_to_integer_power(a,b);
else
    c = matrix_to_scalar_power(a,b);
end

%--------------------------------------------------------------------------

function c = matrix_to_integer_power(a,b)
% matrix ^ integer
ONE = ones(eml_index_class);
n = cast(size(a,1),eml_index_class);
c = eml.nullcopy(eml_expand(eml_scalar_eg(a,b),size(a)));
e = eml_scalar_abs(b);
if e > 0
    firstmult = true;
    while true
        ed2 = eml_scalar_floor(eml_rdivide(e,2));
        if 2*ed2 ~= e
            if firstmult
                % Because b ~= 0, this case must happen eventually.
                c(:) = a(:);
                firstmult = false;
            else
                c = c * a;
            end
        end
        if ed2 == 0
            break
        end
        e = ed2;
        a = a * a;
    end
    if b < 0
        c = inv(c);
    end
else
    % c is the identity of appropriate size, class, and complexness.
    c(:) = 0;
    for k = ONE:n
        c(k,k) = 1;
    end
end

%--------------------------------------------------------------------------

function c = scalar_to_matrix_power(a,b)
% scalar ^ matrix
n = size(b,1);
[V,D] = eig(b);
% c = V * diag(a .^ diag(D)) / V;
for j = 1:n
    r = a .^ D(j,j);
    for i = 1:n
        D(i,j) = V(i,j)*r;
    end
end
if isa(a,class(b))
    c = D / V;
else
    c = single( D / V );
end

%--------------------------------------------------------------------------

function c = matrix_to_scalar_power(a,b)
% matrix ^ general scalar
c = eml.nullcopy(eml_expand(eml_scalar_eg(a,b),size(a)));
if isreal(c)
    % Cannot be an eml_assert since real inputs are supported for the
    % integer-valued b.
    eml_error('EmbeddedMATLAB:mpower:needComplexInput', ...
        'At least one argument must be complex when raising a matrix to a non-integer, scalar power.');
end
n = size(a,1);
[V,D] = eig(a);
% c = V * diag(diag(D) .^ b) / V;
for j = 1:n
    r = D(j,j) .^ b;
    for i = 1:n
        D(i,j) = V(i,j)*r;
    end
end
D = D / V;
if isreal(c)
    % This case can occur in RTW when isreal(a) && isreal(b).
    c(:) = real(D(:));
else
    c(:) = D(:);
end

%--------------------------------------------------------------------------
