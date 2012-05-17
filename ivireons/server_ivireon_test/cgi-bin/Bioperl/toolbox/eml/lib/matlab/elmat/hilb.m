function H = hilb(n,classname)
%Embedded MATLAB Library Function

%   Copyright 1984-2010 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 1, 'Not enough input arguments.');
eml_prefer_const(n);
eml_assert(eml_is_const(n) || eml_option('VariableSizing'), ...
    'First argument must be a constant.');
eml_assert(isa(n,'numeric') && isscalar(n) && isreal(n), ...
    'First argument must be a real integer scalar.');
eml_lib_assert(eml_scalar_floor(n) == n, ...
    'EmbeddedMATLAB:hilb:argMustBeRealIntScalar', ...
    'First argument must be a real integer scalar.');
if nargin == 1
    classname = 'double';
else
    eml_assert(eml_is_float_class(classname), ...
        'Second input must be ''double'' or ''single''.');
end
H = eml.nullcopy(zeros(n,classname));
for j = 1:n
    for i = 1:n
        H(i,j) = 1/cast(i+j-1,classname);
    end
end