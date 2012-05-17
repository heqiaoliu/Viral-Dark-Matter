function H = invhilb(n,classname)
%Embedded MATLAB Library Function

%   Copyright 2002-2010 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 1, 'Not enough input arguments.');
eml_prefer_const(n);
eml_assert(eml_is_const(n) || eml_option('VariableSizing'), ...
    'First argument must be a constant.');
eml_assert(isa(n,'numeric') && isscalar(n) && isreal(n), ...
    'First argument must be a real integer scalar.');
eml_lib_assert(eml_scalar_floor(n) == n, ...
    'EmbeddedMATLAB:invhilb:argMustBeRealIntScalar', ...
    'First argument must be a real integer scalar.');
if nargin == 1
    classname = 'double';
else
    eml_assert(eml_is_float_class(classname), ...
        'Second input must be ''double'' or ''single''.');
end
% To match MATLAB, do arithmetic in double precision, even if the output
% is single precision.
arithclass = 'double';
H = eml.nullcopy(zeros(n,classname));
nc = cast(n,arithclass);
p = nc;
for i = 1:n
    ic = cast(i,arithclass);
    if i > 1
        p = eml_rdivide((nc-ic+1)*p*(nc+ic-1),(ic-1)*(ic-1));
    end
    r = p*p;
    H(i,i) = eml_rdivide(r,(2*ic-1));
    for j = i+1:n
        jc = cast(j,arithclass);
        r = eml_rdivide(-((nc-jc+1)*r*(nc+jc-1)),(jc-1)*(jc-1));
        H(i,j) = eml_rdivide(r,ic+jc-1);
        H(j,i) = eml_rdivide(r,ic+jc-1);
    end
end

