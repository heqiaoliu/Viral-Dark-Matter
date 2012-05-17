function W = wilkinson(n,classname)
% Embedded MATLAB Library Function

%   Copyright 1984-2010 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 1, 'Not enough input arguments.');
eml_prefer_const(n);
eml_assert(eml_is_const(n) || eml_option('VariableSizing'), ...
    'First argument must be a constant.');
eml_assert_valid_size_arg(n);
eml_assert(isa(n,'numeric') && isscalar(n) && isreal(n), ...
    'First argument must be a real integer scalar.');
eml_lib_assert(eml_scalar_floor(n) == n, ...
    'EmbeddedMATLAB:wilkinson:argMustBeRealIntScalar', ...
    'First argument must be a real integer scalar.');
if nargin == 1
    classname = 'double';
else
    eml_assert(eml_is_float_class(classname), ...
        'Second input must be ''double'' or ''single''.');
end
W = zeros(n,classname);
if n > 1
    nd = cast(n,classname);
    m = eml_rdivide(nd-1,2);
    % W = diag(abs(-m:m)) + diag(e,1) + diag(e,-1);
    W(1,1) = m;
    W(2,1) = 1;
    for k = 2:n-1
        W(eml_index_minus(k,1),k) = 1;
        W(k,k) = abs(cast(k,classname)-m-1);
        W(eml_index_plus(k,1),k) = 1;
    end
    W(n-1,n) = 1;
    W(n,n) = m;
end
