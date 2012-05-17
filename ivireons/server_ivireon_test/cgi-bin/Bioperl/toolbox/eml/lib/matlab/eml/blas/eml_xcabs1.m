function d = eml_xcabs1(x)
%Embedded MATLAB Private Function

%   Internal BLAS utility xCABS1(X)

%   Copyright 2007-2008 The MathWorks, Inc.
%#eml

eml_must_inline;
if eml_option('Developer')
    eml_assert(nargin > 0, 'Not enough input arguments.');
    eml_assert(isa(x,'float'), 'Input must be ''double'' or ''single''.');
    eml_assert(isscalar(x), 'Input must be scalar.');
end
d = abs(real(x)) + abs(imag(x));
