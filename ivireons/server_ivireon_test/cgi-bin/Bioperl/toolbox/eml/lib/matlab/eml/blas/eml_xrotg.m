function [a,b,c,s] = eml_xrotg(a,b)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xROTG(A,B,C,S)

%   Copyright 2007-2008 The MathWorks, Inc.
%#eml

if eml_option('Developer')
    eml_assert(nargin == 2, 'Not enough input arguments.');
    eml_assert(isa(a,'float') && isscalar(a), 'A must be a scalar ''double'' or ''single''.');
    eml_assert(isa(b,'float') && isscalar(b), 'B must be a scalar ''double'' or ''single''.');
    eml_assert(isa(a,class(b)) && isreal(a) == isreal(b), ...
        'A and B must have the same class and complexness.');
end
[a,b,c,s] = eml_blas_xrotg(a,b);
