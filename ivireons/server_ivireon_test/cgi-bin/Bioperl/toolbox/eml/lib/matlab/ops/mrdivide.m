function y = mrdivide(A,B)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml
eml.allowpcode('plain');
eml_assert(nargin >= 2, 'Not enough input arguments.');
if eml_is_const(isscalar(B)) && isscalar(B)
    y = A ./ B;
else
    eml_assert(isa(A,'float'), ...
        ['Operation ''mrdivide'' is not defined for values of class ''' class(A) '''.']);
    eml_assert(isa(B,'float'), ...
        ['Operation ''mrdivide'' is not defined for values of class ''' class(B) '''.']);
    eml_lib_assert(size(B,2) == size(A,2), ...
        'MATLAB:dimagree', ...
        'Matrix dimensions must agree.');
    eml_lib_assert(ndims(A) == 2 && ndims(B) == 2, ...
        'MATLAB:mrdivide:inputsMustBe2D', ...
        'Input arguments must be 2-D.');
    y = mldivide(B',A')';
end
