function M = magic(n)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_prefer_const(n);
eml_assert(~eml_option('VariableSizing') || eml_is_const(n), ...
    'Argument must be a constant. MAGIC does not support variable-size output.');
eml_assert(eml_is_const(n), 'Argument must be a constant.');
eml_lib_assert(isa(n,'numeric') && isscalar(n) && isreal(n) && eml_scalar_floor(n) == n, ...
    'EmbeddedMATLAB:magic:argMustBeRealIntScalar', ...
    'Argument must be a real integer scalar.');
if n < 1
    M = [];
    return;
end
nn = double(n);
if mod(nn,2) == 1 % Odd order
    [J,I] = meshgrid(1:nn);
    A = mod(I+J-eml_rdivide(nn+3,2),nn);
    B = mod(I+2*J-2,nn);
    M = nn*A + B + 1;
elseif mod(nn,4) == 0 % Doubly even order
    [J,I] = meshgrid(1:nn);
    M = reshape(1:nn*nn,nn,nn)';
    for z=1:eml_numel(M)
        if fix(eml_rdivide(mod(I(z),4),2)) == fix(eml_rdivide(mod(J(z),4),2))
            M(z) = nn*nn+1 - M(z);
        end
    end
else % Singly even order
    p = eml_rdivide(nn,2);
    MP = magic(p);
    M = [MP MP+2*p^2; MP+3*p^2 MP+p^2];
    if nn == 2
        return
    end
    i = (1:p)';
    k = eml_rdivide(nn-2,4);
    j = [1:k (nn-k+2):nn];
    M([i; i+p],j) = M([i+p; i],j);
    r = k+1;
    s = [1 r];
    M([r; r+p],s) = M([r+p; r],s);
end
